import assert from 'node:assert/strict';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
    api,
    closeTestDatabase,
    connectTestDatabase,
    registerUser,
    resetDatabase,
} from './helpers.ts';

describe('authentication', () => {
    before(connectTestDatabase);
    beforeEach(resetDatabase);
    after(closeTestDatabase);

    it('registers without exposing the password hash', async () => {
        const response = await api.post('/api/v1/auth/register').send({
            name: 'Ada Lovelace',
            email: 'ada@example.com',
            password: 'correct-horse-9',
        });
        assert.equal(response.status, 201);
        assert.equal('passwordHash' in response.body.data.user, false);
        assert.ok(response.body.data.accessToken);
        assert.ok(response.body.data.refreshToken);
    });

    it('rejects a duplicate email', async () => {
        await registerUser();
        const response = await api.post('/api/v1/auth/register').send({
            name: 'Ada Again',
            email: 'ada@example.com',
            password: 'correct-horse-9',
        });
        assert.equal(response.status, 409);
    });

    it('uses the same login error for an unknown email and a wrong password', async () => {
        await registerUser();
        const wrongPassword = await api.post('/api/v1/auth/login').send({
            email: 'ada@example.com',
            password: 'wrong-password',
        });
        const unknownEmail = await api.post('/api/v1/auth/login').send({
            email: 'nobody@example.com',
            password: 'wrong-password',
        });
        assert.equal(wrongPassword.status, 401);
        assert.equal(unknownEmail.status, 401);
        assert.equal(wrongPassword.body.error.message, unknownEmail.body.error.message);
    });

    it('rotates refresh tokens once and revokes the family on reuse', async () => {
        const session = await registerUser();
        const firstRefresh = await api
            .post('/api/v1/auth/refresh')
            .send({ refreshToken: session.refreshToken });
        assert.equal(firstRefresh.status, 200);

        const replay = await api
            .post('/api/v1/auth/refresh')
            .send({ refreshToken: session.refreshToken });
        assert.equal(replay.status, 401);

        const newTokenAfterFamilyRevocation = await api
            .post('/api/v1/auth/refresh')
            .send({ refreshToken: firstRefresh.body.data.refreshToken });
        assert.equal(newTokenAfterFamilyRevocation.status, 401);
    });
});
