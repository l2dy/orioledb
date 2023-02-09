CREATE SCHEMA trigger;
SET SESSION search_path = 'trigger';
CREATE EXTENSION IF NOT EXISTS orioledb;

CREATE TABLE o_test_1 (
	val_1 int,
	val_2 int
) USING orioledb;

INSERT INTO o_test_1 (val_1, val_2)
	(SELECT val_1, val_1 + 100 FROM generate_series (1, 5) val_1);

CREATE OR REPLACE FUNCTION func_trig_o_test_1() RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO o_test_1(val_1) VALUES (OLD.val_1);
	RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER trig_o_test_1 AFTER DELETE ON o_test_1 FOR EACH STATEMENT
	EXECUTE PROCEDURE func_trig_o_test_1();

SELECT * FROM o_test_1;
DELETE FROM o_test_1 WHERE val_1 = 3;
SELECT * FROM o_test_1;

CREATE TABLE o_test_2 (
  val_1 int,
  val_2 int
) USING orioledb;

INSERT INTO o_test_2 (val_1, val_2)
  (SELECT val_1, val_1 + 100 FROM generate_series (1, 5) val_1);

CREATE OR REPLACE FUNCTION func_trig_o_test_2() RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO o_test_2(val_1) VALUES (OLD.val_1);
	RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER trig_o_test_2 AFTER UPDATE ON o_test_2 FOR EACH STATEMENT
	EXECUTE PROCEDURE func_trig_o_test_2();

SELECT * FROM o_test_2;
UPDATE o_test_2 SET val_1 = val_1 + 100;
SELECT * FROM o_test_2;

CREATE TABLE o_test_3 (
    val_1 int,
    val_2 int
) USING orioledb;

INSERT INTO o_test_3 (val_1, val_2)
    (SELECT val_1, val_1 + 100 FROM generate_series (1, 5) val_1);

CREATE OR REPLACE FUNCTION func_trig_o_test_3() RETURNS TRIGGER AS $$
BEGIN
	UPDATE o_test_3 SET val_1 = val_1 WHERE val_1 = OLD.val_1;
	RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER trig_o_test_3 AFTER INSERT ON o_test_3 FOR EACH STATEMENT
	EXECUTE PROCEDURE func_trig_o_test_3();

SELECT * FROM o_test_3;
INSERT INTO o_test_3 (val_1, val_2)
    (SELECT val_1, val_1 + 100 FROM generate_series (1, 5) val_1);
SELECT * FROM o_test_3;

CREATE TABLE o_test_4 (
  val_1 int PRIMARY KEY,
  val_2 text
) USING orioledb;

INSERT INTO o_test_4 (val_1, val_2)
	(SELECT val_1, val_1 + 100 FROM generate_series (1, 5) val_1);

CREATE FUNCTION func_trig_o_test_4() RETURNS TRIGGER AS $$
BEGIN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_1 AFTER UPDATE ON o_test_4
    REFERENCING OLD TABLE AS a NEW TABLE AS i
    FOR EACH STATEMENT EXECUTE FUNCTION func_trig_o_test_4();

SELECT * FROM o_test_4;
UPDATE o_test_4 SET val_1 = val_1;
SELECT * FROM o_test_4;

CREATE TABLE o_test_copy_trigger (
	val_1 serial,
	val_2 int,
	val_3 text,
	val_4 text,
	val_5 text
) USING orioledb;

CREATE FUNCTION func_1 () RETURNS TRIGGER
AS $$
BEGIN
	NEW.val_5 := 'abc'::text;
	return NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trig_1 BEFORE INSERT ON o_test_copy_trigger
	FOR EACH ROW EXECUTE PROCEDURE func_1();

COPY o_test_copy_trigger (val_1, val_2, val_3, val_4, val_5) from stdin;
9999	\N	\\N	\NN	\N
10000	21	31	41	51
\.

SELECT * FROM o_test_copy_trigger;

DROP EXTENSION orioledb CASCADE;
DROP SCHEMA trigger CASCADE;
RESET search_path;