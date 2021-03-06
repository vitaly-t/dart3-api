import { IDatabase, IMain } from 'pg-promise';
import { RoundHit } from 'dart3-sdk';

import { hit as sql } from '../database/sql';

export class HitRepository {
  constructor(private db: IDatabase<any>, private pgp: IMain) {}

  async findRoundHitsByTeamIds(matchTeamsIds: number[]) {
    return this.db.any<RoundHit>(sql.findRoundHitsByTeamIds, {
      matchTeamsIds,
    });
  }
}
