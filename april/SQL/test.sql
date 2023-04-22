-- 어느 회사의 테스트에 나왔던 SQL 문제인데 내 나름대로 풀어보았다

SELECT 
	"DEPTNO" AS 부서번호,
	COUNT("DEPTNO") AS 근무자수,
	SUM("SAL") AS 급여합,
FROM EMP
GROUP BY 부서번호;

SELECT 
	"DEPTNO" AS 부서번호,
	T."부서명" AS 부서명,
	COUNT("DEPTNO") AS 근무자수,
	SUM("SAL") AS 급여합
FROM EMP AS P
JOIN DEPT AS T ON P."DEPTNO" = T."DEPTNO"
GROUP BY P."DEPTNO";