-- all nexon user count exception nexon user sn is null
SELECT COUNT(*)
FROM "NexonUserInfo" u
WHERE u."userNexonSn" != 0

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
	JOIN "NexonUserInfo" u ON b."nexonUserId" = u.id


-- clan match detail
SELECT 
	C."clanName" 클랜명,
	C."ladderPoint",
	C."clanNo" 클랜ID, 
	C."clanMark1" 클랜마크1, 
	C."clanMark2" 클랜마크2, 
	C."winningRate" 전체승률,
	G."matchKey",
	G."matchTime",
	D."result" 승패
FROM "ClanInfo" C
	JOIN "ClanMathDetail" D ON C.id = D."clanId"
		JOIN "Game" G ON D."gameId" = G.id;

-- clan match detail
SELECT
	G."matchKey",
	G."matchTime",
	C."clanName",
	D."result" 승패,
	C."ladderPoint",
	C."winningRate"
FROM "Game" G
	JOIN "ClanMathDetail" D ON G.id = D."gameId"
		JOIN "ClanInfo" C ON D."clanId" = C.id;
		
-- top 5 The clan with the best average winning rate
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
) subquery
GROUP BY "clanName", won_matches, lose_matches, 평균승률
ORDER BY 평균승률 DESC
LIMIT 5;



-- Updates on the last 10 games of the top 5 Clan
SELECT
	outerQuery.*,
	ROW_NUMBER() OVER (PARTITION BY outerQuery."clanName" ORDER BY outerQuery."matchTime" DESC) AS rn
FROM (
SELECT
	subquery.*,	
	ROUND(won_matches * 100.0 / (won_matches + lose_matches), 1) AS 평균승률,
	ROW_NUMBER() OVER (PARTITION BY subquery."clanName" ORDER BY G."matchTime" DESC) AS rn,
	G."matchKey",
	G."matchTime"
FROM (
	SELECT 
		C.id clan_id,
		C."clanName",
		COUNT(CASE WHEN "result" = TRUE THEN 1 END) AS won_matches,
		COUNT(CASE WHEN "result" = FALSE THEN 0 END) AS lose_matches
	FROM "ClanMathDetail" Detail
	JOIN "ClanInfo" C ON Detail."clanId" = C.id
	GROUP BY C."id", C."clanName"
) subquery
JOIN "ClanMathDetail" MD ON subquery.clan_id = MD."clanId"
JOIN "Game" G ON MD."gameId" = G.id
ORDER BY 평균승률 DESC
) outerQuery
WHERE outerQuery."rn" <= 10
