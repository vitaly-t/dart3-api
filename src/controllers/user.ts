import { Context } from 'koa';
import httpStatusCodes from 'http-status-codes';
import { User } from 'dart3-sdk';

import { Auth0Service } from '../services';
import { response, camelize, snakelize } from '../utils';
import { TransactionRepository } from '../repositories';

export class UserController {
  constructor(
    private service = new Auth0Service(),
    private transactionRepo = new TransactionRepository(),
  ) {}

  async get(ctx: Context, userId: string) {
    const user = await this.service.getUser(ctx, userId);
    const bank = await this.transactionRepo.getUserBank(ctx, userId);

    return response(ctx, httpStatusCodes.OK, { ...camelize(user), bank });
  }

  async update(ctx: Context, userId: string, body: Partial<User>) {
    const user = await this.service.updateUser(ctx, userId, snakelize(body));

    return response(ctx, httpStatusCodes.OK, camelize(user));
  }
}