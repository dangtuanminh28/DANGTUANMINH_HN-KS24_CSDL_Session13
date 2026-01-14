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
create trigger after_insert_like
after insert on likes
for each row
BEGIN
	update posts
    set like_count = like_count + 1
    where post_id = new.post_id;
END //
DELIMITER ;

DELIMITER //
create trigger after_delete_like
after delete on likes
for each row
BEGIN
	update posts
    set like_count = like_count - 1
    where post_id = old.post_id;
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

INSERT INTO likes (user_id, post_id, liked_at) VALUES (2, 4, NOW());

SELECT post_id, user_id, content, like_count FROM posts WHERE post_id = 4;
SELECT user_id, username, post_count, total_likes FROM user_statistics;

DELETE FROM likes WHERE user_id = 2 AND post_id = 4;
SELECT user_id, username, post_count, total_likes FROM user_statistics;

DROP TRIGGER IF EXISTS after_insert_like;
DROP TRIGGER IF EXISTS after_delete_like;