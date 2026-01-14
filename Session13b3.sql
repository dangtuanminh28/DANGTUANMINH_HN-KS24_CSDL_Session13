drop database if exists session11;
create database session11;
use session11;

create table users (
	user_id int primary key auto_increment,
    username varchar(50) unique not null,
    email varchar(100) unique not null,
    created_at date,
    follower_count int default(0),
    post_count int default(0)
);

create table posts (
	post_id int primary key auto_increment,
	user_id int,
    content text,
    created_at datetime,
    like_count int default(0),
    foreign key (user_id) references users(user_id)
);

create table likes (
	like_id int primary key auto_increment,
    user_id int,
    post_id int,
    liked_at datetime,
    foreign key (user_id) references users(user_id),
	foreign key (post_id) references posts(post_id)
);

INSERT INTO users (username, email, created_at) VALUES
('alice', 'alice@example.com', '2025-01-01'),
('bob', 'bob@example.com', '2025-01-02'),
('charlie', 'charlie@example.com', '2025-01-03');

INSERT INTO posts (user_id, content, created_at) VALUES
(1, 'Hello world from Alice!', '2025-01-10 10:00:00'),
(1, 'Second post by Alice', '2025-01-10 12:00:00'),
(2, 'Bob first post', '2025-01-11 09:00:00'),
(3, 'Charlie sharing thoughts', '2025-01-12 15:00:00');

INSERT INTO likes (user_id, post_id, liked_at) VALUES
(2, 1, '2025-01-10 11:00:00'),
(3, 1, '2025-01-10 13:00:00'),
(1, 3, '2025-01-11 10:00:00'),
(3, 4, '2025-01-12 16:00:00');

DELIMITER //
CREATE TRIGGER before_insert_like
BEFORE INSERT ON likes
FOR EACH ROW
BEGIN
    DECLARE author_id INT;
    -- Lấy user_id của chủ bài viết
    SELECT user_id INTO author_id FROM posts WHERE post_id = NEW.post_id;
    
    IF NEW.user_id = author_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi không thể like bài!';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_update_like
AFTER UPDATE ON likes
FOR EACH ROW
BEGIN
    IF OLD.post_id <> NEW.post_id THEN
        -- Giảm like ở bài viết cũ
        UPDATE posts SET like_count = like_count - 1 WHERE post_id = OLD.post_id;
        -- Tăng like ở bài viết mới
        UPDATE posts SET like_count = like_count + 1 WHERE post_id = NEW.post_id;
    END IF;
END //
DELIMITER ;

CREATE VIEW user_statistics AS
SELECT 
    u.user_id, 
    u.username, 
    u.post_count, 
    COUNT(p.like_count) AS total_likes
FROM users u 
JOIN posts p ON u.user_id = p.user_id
GROUP BY u.user_id, u.username, u.post_count;
-- Test bug
INSERT INTO likes (user_id, post_id, liked_at) VALUES (1, 1, NOW());
-- Test hợp lệ
INSERT INTO likes (user_id, post_id, liked_at) VALUES (2, 4, NOW());
SELECT post_id, like_count FROM posts WHERE post_id = 4;

-- Update sang bài viết khác
UPDATE likes SET post_id = 3 WHERE user_id = 2 AND post_id = 4;
SELECT post_id, like_count FROM posts WHERE post_id IN (3, 4);
-- Xóa like
DELETE FROM likes WHERE user_id = 2 AND post_id = 3;
SELECT post_id, like_count FROM posts WHERE post_id = 3;

-- Kiểm tra truy vấn
SELECT post_id, content, like_count FROM posts;
SELECT user_id, username, post_count, total_likes FROM user_statistics;

DROP TRIGGER IF EXISTS before_insert_like;
DROP TRIGGER IF EXISTS after_update_like;