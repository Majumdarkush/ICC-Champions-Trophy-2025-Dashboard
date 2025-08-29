-- Create Database (optional)
CREATE DATABASE ICCChampionsTrophy2025;


-- Use the created database
USE ICCChampionsTrophy2025;


-- Create Table to store match results
CREATE TABLE [dbo].[ICC champions_trophy_matches_results 2025] (
    Team1 NVARCHAR(50),
    Team2 NVARCHAR(50),
    Toss NVARCHAR(100),
    MatchDays NVARCHAR(50),
    Winner NVARCHAR(50),
    PlayerOfTheMatch NVARCHAR(100),
    Margin NVARCHAR(50),
    Ground NVARCHAR(100),
    MatchDate DATE,
    ODIIntMatch NVARCHAR(50),
    Team1AvgBattingRanking FLOAT,
    Team2AvgBattingRanking FLOAT,
    Team1AvgBowlingRanking FLOAT,
    Team2AvgBowlingRanking FLOAT,
    Team1TotalCTsParticipated INT,
    Team1TotalCTsWon INT,
    Team2TotalCTsParticipated INT,
    Team2TotalCTsWon INT,
    Team1WLRatioOverTeam2 FLOAT
);

SELECT * FROM [dbo].[ICC champions_trophy_matches_results 2025]

-- 1. Total matches won by each team

SELECT Winner, COUNT(*) AS MatchesWon
FROM [dbo].[ICC champions_trophy_matches_results 2025]
WHERE Winner <> 'no result'
GROUP BY Winner
ORDER BY MatchesWon DESC;

-- 2. Player with the most "Player of the Match" awards

SELECT Player_of_the_Match, COUNT(*) AS AwardsCount
FROM [dbo].[ICC champions_trophy_matches_results 2025]
WHERE Player_of_the_Match <> ''
GROUP BY Player_of_the_match
ORDER BY AwardsCount DESC;

-- 3. Average margin of victory by margin type (runs, wickets)

SELECT 
    CASE 
        WHEN Margin LIKE '%runs%' THEN 'Runs' 
        WHEN Margin LIKE '%wickets%' THEN 'Wickets'
        ELSE 'Other' 
    END AS MarginType,
    AVG(CAST(SUBSTRING(Margin, 1, CHARINDEX(' ', Margin) - 1) AS FLOAT)) AS AvgMargin
FROM [dbo].[ICC champions_trophy_matches_results 2025]
WHERE Margin <> '-'
GROUP BY 
    CASE 
        WHEN Margin LIKE '%runs%' THEN 'Runs' 
        WHEN Margin LIKE '%wickets%' THEN 'Wickets'
        ELSE 'Other' 
    END;

-- 4. Win-loss ratio of India against each team

SELECT Team2 AS Opponent, MAX(Team1_W_L_ratio_over_Team2) AS WinLossRatio
FROM [dbo].[ICC champions_trophy_matches_results 2025]
WHERE Team1 = 'India'
GROUP BY Team2;

-- 5. Number of matches played and won per ground

SELECT Ground, COUNT(*) AS MatchesPlayed, 
       SUM(CASE WHEN Winner = Team1 OR Winner = Team2 THEN 1 ELSE 0 END) AS MatchesWithResult
FROM [dbo].[ICC champions_trophy_matches_results 2025]
GROUP BY Ground;

--6. Number of matches played each month (year-month)

SELECT FORMAT(Match_Date, 'yyyy-MM') AS YearMonth, COUNT(*) AS MatchesPlayed
FROM [dbo].[ICC champions_trophy_matches_results 2025]
GROUP BY FORMAT(Match_Date, 'yyyy-MM')
ORDER BY YearMonth;

--7. Teams with the highest average batting ranking in matches

SELECT Team1 AS Team, AVG(Team1_Avg_Batting_Ranking) AS AvgBattingRanking
FROM [dbo].[ICC champions_trophy_matches_results 2025]
GROUP BY Team1
UNION ALL
SELECT Team2 AS Team, AVG(Team2_Avg_Batting_Ranking) AS AvgBattingRanking
FROM [dbo].[ICC champions_trophy_matches_results 2025]
GROUP BY Team2
ORDER BY AvgBattingRanking DESC;

-- 8. Top grounds by number of matches hosted

SELECT Ground, COUNT(*) AS MatchesHosted
FROM [dbo].[ICC champions_trophy_matches_results 2025]
GROUP BY Ground
ORDER BY MatchesHosted DESC;

-- 9. Matches won by teams electing to field or bat first after toss

SELECT TossChoice, COUNT(*) AS MatchesWon
FROM (
    SELECT 
        CASE 
            WHEN Toss LIKE '%bat first%' THEN 'Bat First' 
            WHEN Toss LIKE '%field first%' THEN 'Field First' 
            ELSE 'Unknown' 
        END AS TossChoice,
        Winner,
        Team1,
        Team2
    FROM [dbo].[ICC champions_trophy_matches_results 2025]
) AS TossResults
WHERE (TossChoice = 'Bat First' AND Winner IN (Team1, Team2))
GROUP BY TossChoice;

--10. Player of the Match awards by ground

SELECT Ground, Player_of_the_Match, COUNT(*) AS AwardsCount
FROM [dbo].[ICC champions_trophy_matches_results 2025]
WHERE Player_of_the_Match <> ''
GROUP BY Ground, Player_of_the_Match
ORDER BY AwardsCount DESC;
