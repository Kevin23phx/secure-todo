import { AppError } from '../../shared/errors.ts';
import { Todo } from './todo.model.ts';
import type {
    CreateTodoInput,
    ListTodosQuery,
    UpdateTodoInput,
} from './todo.schemas.ts';

// Every database operation is scoped by the authenticated owner id.
export async function listTodos(ownerId: string, query: ListTodosQuery) {
    const { page, limit, completed } = query;
    const filter = {
        owner: ownerId,
        ...(completed !== undefined ? { completed } : {}),
    };

    const [items, total] = await Promise.all([
        Todo.find(filter)
            .sort({ createdAt: -1 })
            .skip((page - 1) * limit)
            .limit(limit),
        Todo.countDocuments(filter),
    ]);

    return { items, total, page, limit };
}

export async function createTodo(ownerId: string, input: CreateTodoInput) {
    return Todo.create({ ...input, owner: ownerId });
}

export async function getTodo(ownerId: string, id: string) {
    const todo = await Todo.findOne({ _id: id, owner: ownerId });
    if (!todo) throw AppError.notFound('Todo not found');
    return todo;
}

export async function updateTodo(
    ownerId: string,
    id: string,
    input: UpdateTodoInput,
) {
    const todo = await Todo.findOneAndUpdate(
        { _id: id, owner: ownerId },
        { $set: input },
        { returnDocument: 'after', runValidators: true },
    );
    if (!todo) throw AppError.notFound('Todo not found');
    return todo;
}

export async function deleteTodo(ownerId: string, id: string): Promise<void> {
    const todo = await Todo.findOneAndDelete({ _id: id, owner: ownerId });
    if (!todo) throw AppError.notFound('Todo not found');
}
