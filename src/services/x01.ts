import { GameType, Score, RoundScore } from 'dart3-sdk';

import { GameService } from './game';

export class X01Service extends GameService {
  getStartScore(): number {
    switch (this.game.type) {
      case GameType.Five01DoubleInDoubleOut:
      case GameType.Five01SingleInDoubleOut:
        return 501;
      case GameType.Three01SDoubleInDoubleOut:
      case GameType.Three01SingleInDoubleOut:
        return 301;
    }
  }

  getRoundScore(scores: Score[], round: number, currentScore: number): RoundScore {
    throw new Error('Method not implemented.');
  }

  // runLastTurn(round: number, total: number): boolean {
  //   throw new Error('Method not implemented.');
  // }

  // lastTurn(total: number, round: number, turn: number) {
  //   throw new Error('Method not implemented.');
  // }
}
