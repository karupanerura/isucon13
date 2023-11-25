INSERT INTO livestream_scores SELECT * FROM (SELECT l.id, IFNULL(SUM(lc.tip), 0) AS tips FROM livestreams l LEFT JOIN livecomments lc ON lc.livestream_id = l.id GROUP BY l.id) AS q ON DUPLICA
TE KEY UPDATE score = score + q.tips;
INSERT INTO livestream_scores SELECT * FROM (SELECT livestream_id, COUNT(*) AS reactions FROM reactions GROUP BY livestream_id) AS q ON DUPLICATE KEY UPDATE score = score + q.reactions;

INSERT INTO user_scores SELECT * FROM (SELECT u.id, COUNT(*) AS reactions, u.name FROM users u LEFT JOIN livestreams l ON l.user_id = u.id LEFT JOIN reactions r ON r.livestream_id = l.id GROUP BY u.id) AS q ON DUPLICATE KEY UPDATE score = score + q.reactions;
INSERT INTO user_scores SELECT * FROM (SELECT u.id, IFNULL(SUM(lc.tip), 0) AS tips, u.name FROM users u LEFT JOIN livestreams l ON l.user_id = u.id LEFT JOIN livecomments lc ON lc.livestream_
id = l.id GROUP BY u.id) AS q ON DUPLICATE KEY UPDATE score = score + q.tips;