CREATE EXTENSION pgcrypto;

CREATE TABLE IF NOT EXISTS player (
  id                    SERIAL,
  user_id               CHAR(30)      NOT NULL,
  name                  VARCHAR(64)   NOT NULL,
  email                 VARCHAR       NOT NULL,
  balance               NUMERIC(10,2) DEFAULT 0,
  pin                   VARCHAR(60)   NOT NULL,
  created_at            TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  deleted_at            TIMESTAMP,
  color                 CHAR(7)       DEFAULT '#FFFFFF',
  avatar                VARCHAR,
  xp                    INTEGER       DEFAULT 0,
  high_score            SMALLINT      DEFAULT 0,
  one_hundred_eighties  SMALLINT      DEFAULT 0,
  nine_darters          SMALLINT      DEFAULT 0,
  PRIMARY KEY (id)
);

CREATE TYPE transaction_type AS ENUM (
  'system',
  'bet',
  'win',
  'jackpot',
  'deposit',
  'withdrawal',
  'transfer'
);

CREATE TABLE IF NOT EXISTS transaction (
  id            SERIAL,
  player_id     INTEGER,
  type          transaction_type  NOT NULL,
  debit         NUMERIC(10,2)      DEFAULT 0,
  credit        NUMERIC(10,2)      DEFAULT 0,
  balance       NUMERIC(10,2)     NOT NULL CHECK (balance >= 0),
  created_at    TIMESTAMP         DEFAULT CURRENT_TIMESTAMP,
  description  VARCHAR(100),
  PRIMARY KEY (id),
  FOREIGN KEY (player_id) REFERENCES player (id)
);

CREATE TYPE game_type AS ENUM (
  'havleit',
  'legs',
  '301_si_do',
  '501_si_do',
  '301_di_do',
  '501_di_do'
);

CREATE TABLE IF NOT EXISTS game (
  id              SERIAL,
  user_id         CHAR(30)  NOT NULL,
  type            game_type NOT NULL,
  legs            SMALLINT  DEFAULT 1,
  sets            SMALLINT  DEFAULT 1,
  game_player_id  INTEGER   NOT NULL,
  bet             SMALLINT  NOT NULL,
  started_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ended_at        TIMESTAMP,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS game_player (
  id        SERIAL,
  game_id   INTEGER,
  player_id INTEGER,
  turn      SMALLINT  NOT NULL,
  leg       SMALLINT  DEFAULT 1,
  set       SMALLINT  DEFAULT 1,
  score     SMALLINT  DEFAULT 0,
  position  SMALLINT  DEFAULT 0,
  xp        SMALLINT  DEFAULT 0,
  win       SMALLINT  DEFAULT 0,
  PRIMARY KEY (id),
  FOREIGN KEY (game_id) REFERENCES game (id),
  FOREIGN KEY (player_id) REFERENCES player (id)
);

ALTER TABLE game ADD FOREIGN KEY (game_player_id) REFERENCES game_player (id);

CREATE TABLE IF NOT EXISTS game_score (
  id              SERIAL,
  game_player_id  INTEGER,
  leg             SMALLINT  NOT NULL,
  set             SMALLINT  NOT NULL,
  valid           BOOLEAN   NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (game_player_id) REFERENCES game_player (id)
);

CREATE TABLE IF NOT EXISTS game_dart (
  id            SERIAL,
  game_score_id INTEGER,
  dart          SMALLINT  NOT NULL,
  score         SMALLINT  NOT NULL,
  multiplier    SMALLINT  NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (game_score_id) REFERENCES game_score (id)
);

CREATE TABLE IF NOT EXISTS jackpot (
  id          SERIAL,
  game_id     INTEGER,
  player_id   INTEGER,
  user_id     CHAR(30)      NOT NULL,
  value       NUMERIC(5,2)  DEFAULT 0,
  next_value  NUMERIC(5,2)  DEFAULT 0,
  started_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  won_at      TIMESTAMP,
  PRIMARY KEY (id),
  FOREIGN KEY (game_id) REFERENCES game (id),
  FOREIGN KEY (player_id) REFERENCES player (id)
);

CREATE OR REPLACE FUNCTION update_player_balance()
  RETURNS TRIGGER AS $$
BEGIN
  UPDATE player SET balance = NEW.balance WHERE id = NEW.player_id;
  RETURN NEW;
END; $$ language plpgsql;

CREATE TRIGGER new_transaction AFTER INSERT ON transaction FOR EACH ROW EXECUTE PROCEDURE update_player_balance();

CREATE OR REPLACE FUNCTION init_player_balace()
  RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO transaction (player_id, type, balance) values(NEW.id, 'system', 0);
  RETURN NEW;
END; $$ language plpgsql;

CREATE TRIGGER new_player AFTER INSERT ON player FOR EACH ROW EXECUTE PROCEDURE init_player_balace();
