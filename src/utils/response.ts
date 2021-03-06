import { Context } from 'koa';
import httpStatusCodes from 'http-status-codes';

export const errorResponse = (ctx: Context, status: number, error?: any) => {
  if (status >= 500) {
    ctx.logger.error({ status, ...(error && error) });
  } else {
    ctx.logger.info({ status, ...(error && error) });
  }

  ctx.throw(status, httpStatusCodes.getStatusText(status));
};

export const response = (ctx: Context, status: number, body?: any) => {
  ctx.status = status;
  ctx.body = body;

  return ctx;
};
