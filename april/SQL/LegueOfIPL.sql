-- all nexon user count exception nexon user sn is null
SELECT COUNT(*)
FROM "NexonUserInfo" u
WHERE u."userNexonSn" <> 0

-- all game count
SELECT COUNT(*)
FROM "Game"

-- user ladder point TOP 3
SELECT DISTINCT ON(u."ladderPoint")
	b.nickname,
	u."userNexonSn",
	u."ladderPoint"
FROM "NexonUserInfo" u
	JOIN "NexonUserBattleLog" b
	ON u.id = b."nexonUserId"
WHERE u."userNexonSn" != 0
ORDER BY u."ladderPoint" DESC
LIMIT 3;

-- clan ladder point TOP 3
SELECT DISTINCT ON(c."ladderPoint")
	c."clanName",
	c."ladderPoint",
	c."clanMark1",
	c."clanMark2"
FROM "ClanInfo" c
ORDER BY c."ladderPoint" DESC
LIMIT 3;

-- user match detail
SELECT b.nickname,
	   b.kill,
	   b.death,
	   b.assist,
	   b.grade,
	   CASE
	   		WHEN (b.kill + b.death) = 0 THEN NULL
	   		ELSE b.kill * 100 / (b.kill + b.death)
	   END AS this_match_kd,
	   u."winningRate",
	   g."matchKey",
	   g."matchTime"
FROM "NexonUserBattleLog" b
JOIN "Game" g  ON b."gameId" = g.id
JOIN "NexonUserInfo" u ON b."nexonUserId" = u.id;


-- clan match detail
SELECT
	"clanName" 클랜명,
	"ladderPoint",
	"clanNo" 클랜ID,
	CASE
		WHEN D."isRedTeam" = TRUE THEN '선블루'
		ELSE '선레드'
	END AS position,
	CASE
		WHEN D."result" = TRUE THEN '승리'
		ELSE '패배'
	END AS 승패,	
	"winningRate" 전체승률,
	"clanMark1" 클랜마크1, 
	"clanMark2" 클랜마크2,
	G."matchKey",
	G."matchTime"
FROM "ClanInfo" C
JOIN "ClanMathDetail" D ON C.id = D."clanId"
JOIN "Game" G ON D."gameId" = G.id;

-- clan match detail
SELECT 
	G."matchKey", 
	C1."clanName" AS clan1_name, 
	D1."result" AS clan1_result, 
	C2."clanName" AS clan2_name, 
	D2."result" AS clan2_result
FROM "Game" G
JOIN "ClanMathDetail" D1 ON G."id" = D1."gameId"
JOIN "ClanInfo" C1 ON D1."clanId" = C1."id"
JOIN "ClanMathDetail" D2 ON G."id" = D2."gameId"
JOIN "ClanInfo" C2 ON D2."clanId" = C2."id"
WHERE D1."isRedTeam" = TRUE AND D2."isRedTeam" = FALSE;

-- top 5 The clan with the best average winning rate And more than 10 match
SELECT
	"clanName",
	won_matches,
	lose_matches,
	ROUND(won_matches * 100.0 / (won_matches + lose_matches), 1) AS 평균승률
FROM (
	SELECT 
		C.id,
		C."clanName",
		COUNT(CASE WHEN "result" = TRUE THEN 1 END) AS won_matches,
		COUNT(CASE WHEN "result" = FALSE THEN 0 END) AS lose_matches
	FROM "ClanMathDetail" Detail
	JOIN "ClanInfo" C ON Detail."clanId" = C.id
	GROUP BY C."id", C."clanName"
) AS subquery
GROUP BY "clanName", won_matches, lose_matches, 평균승률
HAVING won_matches + lose_matches > 10
ORDER BY 평균승률 DESC
LIMIT 5; 


-- Game Detail The top 5 winning percentage of the clan's last 10 games played over 10 times
WITH ClanMatch AS (
	SELECT 
		C."id",
		C."clanName",
		COUNT(CASE WHEN "result" = TRUE THEN 1 END) AS won_matches,
		COUNT(CASE WHEN "result" = FALSE THEN 1 END) AS lose_matches,
		ROUND(COUNT(CASE WHEN "result" = TRUE THEN 1 END) * 100.0 / COUNT(*), 1) AS average_win_rate
	FROM "ClanMathDetail" Detail
	JOIN "ClanInfo" C ON Detail."clanId" = C.id 
	GROUP BY C."id", C."clanName"
	HAVING COUNT(*) > 10
	ORDER BY average_win_rate DESC	
	LIMIT 5
), TopClans AS (
	SELECT
		ClanMatch."id",
		"clanName",
		CASE D."result"
			WHEN TRUE THEN '승리'
			ELSE '패배'
		END AS 승패,
		CASE D."isRedTeam"
			WHEN TRUE THEN '선블루'
			ELSE '선레드'		
		END AS team_position,
		G."matchKey",
		G."matchTime",
		ROW_NUMBER() OVER (PARTITION BY "clanName" ORDER BY G."matchTime" DESC) AS match_index
	FROM ClanMatch
	JOIN "ClanMathDetail" D ON ClanMatch."id" = D."clanId"
	JOIN "Game" G ON D."gameId" = G."id"
	ORDER BY average_win_rate DESC
)
SELECT 
	T."clanName",
	T.team_position,
	T.승패,
	T."matchKey",
	T."matchTime"
FROM TopClans AS T
WHERE T.match_index <= 10
LIMIT 10 * (SELECT COUNT(*) FROM ClanMatch);

-- 

WITH ClanMatch AS (
	SELECT 
		C."id",
		C."clanName",
		COUNT(CASE WHEN "result" = TRUE THEN 1 END) AS won_matches,
		COUNT(CASE WHEN "result" = FALSE THEN 1 END) AS lose_matches,
		ROUND(COUNT(CASE WHEN "result" = TRUE THEN 1 END) * 100.0 / COUNT(*), 1) AS average_win_rate
	FROM "ClanMathDetail" Detail
	JOIN "ClanInfo" C ON Detail."clanId" = C.id 
	GROUP BY C."id", C."clanName"
	HAVING COUNT(*) > 10
	ORDER BY average_win_rate DESC	
	LIMIT 5
), TopClans AS (
	SELECT
		ClanMatch."id",
		"clanName",
		CASE D."result"
			WHEN TRUE THEN '승리'
			ELSE '패배'
		END AS 승패,
		CASE D."isRedTeam"
			WHEN TRUE THEN '선블루'
			ELSE '선레드'		
		END AS team_position,
		G."matchKey",
		G."matchTime",
		ROW_NUMBER() OVER (PARTITION BY "clanName" ORDER BY G."matchTime" DESC) AS match_index
	FROM ClanMatch
	JOIN "ClanMathDetail" D ON ClanMatch."id" = D."clanId"
	JOIN "Game" G ON D."gameId" = G."id"
	ORDER BY average_win_rate DESC
), RecentTenGame AS (
SELECT 
	T."clanName",
	T.team_position,
	T.승패,
	T."matchKey",
	T."matchTime"
FROM TopClans AS T
WHERE T.match_index <= 10
LIMIT 10 * (SELECT COUNT(*) FROM ClanMatch)
)
SELECT
	"clanName",
	ROUND(COUNT(CASE WHEN R.승패 = '승리' THEN 1 END) * 100.0 / COUNT(*), 1) AS recent_10_game_win_rate
FROM RecentTenGame R  
GROUP BY "clanName";