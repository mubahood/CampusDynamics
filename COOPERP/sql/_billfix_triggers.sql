USE campus_dynamics_accounts;

DROP TRIGGER IF EXISTS trg_prevent_duplicate_bill;
DROP TRIGGER IF EXISTS trg_sync_bill_uniqueness_delete;

DELIMITER $$

CREATE TRIGGER trg_prevent_duplicate_bill
BEFORE INSERT ON fin_studentfeestracking
FOR EACH ROW
BEGIN
    IF NEW.trans_type = 'Bill' THEN
        INSERT INTO fin_bill_uniqueness (regno, acadyear, semester, item_code, tid)
        VALUES (NEW.regno, NEW.acadyear, NEW.semester, NEW.item_code, 0);
    END IF;
END$$

CREATE TRIGGER trg_sync_bill_uniqueness_delete
AFTER DELETE ON fin_studentfeestracking
FOR EACH ROW
BEGIN
    IF OLD.trans_type = 'Bill' THEN
        DELETE FROM fin_bill_uniqueness
        WHERE regno = OLD.regno AND acadyear = OLD.acadyear
          AND semester = OLD.semester AND item_code = OLD.item_code;
    END IF;
END$$

DELIMITER ;
