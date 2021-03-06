import httpStatusCodes from 'http-status-codes';
import { Context } from 'koa';
import { Game, GameType } from 'dart3-sdk';

import { errorResponse } from '../utils';
import { db, pgp } from '../database';
import { GameService, X01Service, LegsService, HalveItService } from '../services';
import { game as sql } from '../database/sql';

const getGameService = (game: Game): GameService => {
  switch (game.type) {
    case GameType.Five01DoubleInDoubleOut:
    case GameType.Five01SingleInDoubleOut:
    case GameType.Three01SDoubleInDoubleOut:
    case GameType.Three01SingleInDoubleOut:
      return new X01Service(game, db, pgp);
    case GameType.Legs:
      return new LegsService(game, db, pgp);
    case GameType.HalveIt:
      return new HalveItService(game, db, pgp);
  }
};

export const gameService = async (ctx: Context, next: Function) => {
  let game: Game;

  try {
    game = await db.one(sql.findCurrent, { userId: ctx.state.userId });
  } catch (err) {
    errorResponse(ctx, httpStatusCodes.NOT_FOUND);
  }

  const service = getGameService(game);

  ctx.state = { ...ctx.state, service };

  return next();
};
