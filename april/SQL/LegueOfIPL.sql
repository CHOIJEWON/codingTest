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