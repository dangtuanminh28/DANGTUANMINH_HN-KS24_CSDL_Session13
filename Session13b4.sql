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

create table post_history  (
	history_id int primary key auto_increment,
    post_id int,
    old_content text,
    new_content text,
    changed_at datetime,
    changed_by_user_id int,
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

INSERT INTO post_history (post_id, old_content, new_content, changed_at, changed_by_user_id) VALUES
(1, 'Hello world from Alice!', 'Alice edit lần 1: Chào ngày mới!', '2025-01-14 08:00:00', 1),
(1, 'Alice edit lần 1: Chào ngày mới!', 'Alice edit lần 2: Chào buổi sáng tốt lành!', '2025-01-14 09:30:00', 1),
(2, 'Second post by Alice', 'Nội dung bài 2 đã cập nhật bản mới', '2025-01-14 10:15:00', 1),
(3, 'Bob first post', 'Bob cập nhật: Cảm ơn các bạn đã đọc!', '2025-01-14 11:00:00', 2),
(4, 'Bob cập nhật: Cảm ơn các bạn đã đọc!', 'Bob cập nhật: eLearning', '2025-01-14 12:00:00', 2);

DELIMITER //
CREATE TRIGGER before_update_posts
BEFORE UPDATE ON posts
FOR EACH ROW
BEGIN
    IF OLD.content <> NEW.content THEN
        INSERT INTO post_history ( post_id, old_content, new_content, changed_at, changed_by_user_id)
        VALUES (
            OLD.post_id, 
            OLD.content, 
            NEW.content, 
            NOW(), 
            OLD.user_id
        );
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_delete_posts
AFTER DELETE ON posts
FOR EACH ROW
BEGIN
    DELETE FROM likes WHERE post_id = OLD.post_id;
    UPDATE users SET post_count = post_count - 1 WHERE user_id = OLD.user_id;
END //
DELIMITER ;

UPDATE posts SET content = 'Nội dung đã được chỉnh sửa lần 1' WHERE post_id = 1;
UPDATE posts SET content = 'Nội dung đã được chỉnh sửa lần 2' WHERE post_id = 1;
SELECT history_id, post_id, old_content, new_content, changed_at, changed_by_user_id FROM post_history;

SELECT post_id, content, like_count FROM posts WHERE post_id = 1;

DROP TRIGGER IF EXISTS before_update_posts;
DROP TRIGGER IF EXISTS after_delete_posts;