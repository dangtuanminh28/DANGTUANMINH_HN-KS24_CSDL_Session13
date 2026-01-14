drop database if exists session13btth;
create database session13btth;
use session13btth;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    total_posts INT DEFAULT 0
);

CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content TEXT,
    created_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE post_audits (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    old_content TEXT,
    new_content TEXT,
    changed_at DATETIME
);

INSERT INTO users (username, total_posts) VALUES
('Minh', 0),
('Bình', 0),
('Lê', 0),
('Dũng', 0),
('Khánh', 0),
('Duy', 0);

INSERT INTO posts (user_id, content, created_at) VALUES
(1, 'Bài viết đầu tiên của Minh', '2025-01-01 08:00:00'),
(1, 'Minh chia sẻ kinh nghiệm học SQL', '2025-01-01 09:00:00'),
(2, 'Bình đăng bài về công nghệ thông tin', '2025-01-02 10:30:00'),
(3, 'Lê chia sẻ trải nghiệm du lịch', '2025-01-03 14:00:00'),
(4, 'Dũng viết về lập trình C cơ bản', '2025-01-04 16:15:00'),
(5, 'Khánh chia sẻ mẹo học MySQL hiệu quả', '2025-01-05 18:45:00');

INSERT INTO post_audits (post_id, old_content, new_content, changed_at) VALUES
(1, 'Bài viết đầu tiên của An', 'An cập nhật bài viết lần 1', '2025-01-06 08:30:00'),
(1, 'An cập nhật bài viết lần 1', 'An cập nhật bài viết lần 2', '2025-01-06 09:00:00'),
(2, 'An chia sẻ kinh nghiệm học SQL', 'An chia sẻ mẹo học SQL nâng cao', '2025-01-07 10:00:00'),
(3, 'Bình đăng bài về công nghệ thông tin', 'Bình cập nhật xu hướng AI', '2025-01-08 11:30:00'),
(4, 'Chí chia sẻ trải nghiệm du lịch', 'Chí chia sẻ du lịch Đà Lạt', '2025-01-09 14:00:00'),
(5, 'Dũng viết về lập trình C cơ bản', 'Dũng viết về con trỏ trong C', '2025-01-10 16:00:00');

-- Câu 1
DELIMITER //
CREATE TRIGGER tg_CheckPostContent
BEFORE INSERT ON posts
FOR EACH ROW
BEGIN
    IF NEW.content IS NULL OR TRIM(NEW.content) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nội dung bài viết không được để trống!';
    END IF;
END//
DELIMITER ;

-- Câu 2
DELIMITER //
CREATE TRIGGER tg_UpdatePostCountAfterInsert
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
    UPDATE users
    SET total_posts = total_posts + 1
    WHERE user_id = NEW.user_id;
END//
DELIMITER ;

-- Câu 3
DELIMITER //
CREATE TRIGGER tg_LogPostChanges
AFTER UPDATE ON posts
FOR EACH ROW
BEGIN
    IF OLD.content <> NEW.content THEN
        INSERT INTO post_audits (
            post_id,
            old_content,
            new_content,
            changed_at
        )
        VALUES (
            OLD.post_id,
            OLD.content,
            NEW.content,
            NOW()
        );
    END IF;
END//
DELIMITER ;

-- Câu 4
DELIMITER //
CREATE TRIGGER tg_UpdatePostCountAfterDelete
AFTER DELETE ON posts
FOR EACH ROW
BEGIN
    UPDATE users
    SET total_posts = total_posts - 1
    WHERE user_id = OLD.user_id;
END//
DELIMITER ;

SELECT user_id, username, total_posts FROM users;

DROP TRIGGER IF EXISTS tg_CheckPostContent;
DROP TRIGGER IF EXISTS tg_UpdatePostCountAfterInsert;
DROP TRIGGER IF EXISTS tg_LogPostChanges;
DROP TRIGGER IF EXISTS tg_UpdatePostCountAfterDelete;