# ICC Champions Trophy 2025 – Match Insights Dashboard

### Dashboard Link: https://app.powerbi.com/links/sXzNVKspin?ctid=edc5c3bf-4ab5-4697-84fa-41b44eb08b5e&pbi_source=linkShare

## Problem Statement

The ICC Champions Trophy 2025 Match Insights Dashboard provides actionable insights into match performances, player contributions, and team comparisons.

It enables:
Tracking winning patterns (toss decision, batting/fielding first, venues).

Identifying top players with most Player of the Match awards.

Comparing team win/loss ratios against opponents.

Analyzing average margins of victory (runs/wickets).

Helping selectors/analysts refine strategies and selections.

### Steps Followed

Step 1: Loaded raw dataset Cricket Data.csv into Power BI Desktop.

Step 2: Used Power Query for cleaning & transformations (removed nulls, created Year-Month, Toss Choice, Margin Type).

Step 3: Wrote SQL queries (Project.sql) to validate match stats.

Step 4: Created calculated columns for margin classification, opponent, and result flags.

Step 5: Built DAX measures for KPIs (matches, wins, W/L ratio, average margins, top awards).

Step 6: Designed dashboard with cards, slicers, bar charts, and tables.

Step 7: Published .pbix to Power BI Service.

## SQL Queries

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


## DAX Measures

-- Total Matches
Total Matches = COUNTROWS(MatchResults)

-- Total Wins
Total Wins = COUNTROWS(FILTER(MatchResults, MatchResults[Winner] <> BLANK()))

-- Total Losses
Total Losses = [Total Matches] - [Total Wins]

-- Win %
Win % = DIVIDE([Total Wins], [Total Matches], 0)

-- Matches with Result
Has Result = IF(ISBLANK(MatchResults[Winner]), 0, 1)

-- Average Margin (all results)
Avg Margin = AVERAGE(MatchResults[MarginValue])

-- Average Margin (Runs only)
Avg Margin Runs = AVERAGEX(FILTER(MatchResults, MatchResults[MarginType] = "Runs"), MatchResults[MarginValue])

-- Average Margin (Wickets only)
Avg Margin Wickets = AVERAGEX(FILTER(MatchResults, MatchResults[MarginType] = "Wickets"), MatchResults[MarginValue])

-- Player of the Match Awards
Player Awards = COUNT(MatchResults[Player of the Match])

-- Top Awarded Player
Top Player =
TOPN(
    1,
    SUMMARIZE(
        MatchResults,
        MatchResults[Player of the Match],
        "Awards", COUNTROWS(MatchResults)
    ),
    [Awards], DESC
)

-- Team vs Team W/L Ratio
W_L Ratio = DIVIDE([Total Wins], [Total Losses], 0)

-- Matches by Toss Decision
Bat First Wins =
COUNTROWS(
    FILTER(
        MatchResults,
        MatchResults[Toss Winner] = MatchResults[Winner]
        && MatchResults[Toss Decision] = "Bat"
    )
)

Field First Wins =
COUNTROWS(
    FILTER(
        MatchResults,
        MatchResults[Toss Winner] = MatchResults[Winner]
        && MatchResults[Toss Decision] = "Field"
    )
)
-- Top Awarded Player
Top Player = TOPN(1, SUMMARIZE(Matches, Matches[Player of the Match], "Awards", COUNTROWS(Matches)), [Awards], DESC)

-- Team vs Team W/L Ratio
W_L Ratio = DIVIDE([Total Wins], [Total Losses], 0)

-- Matches by Toss Decision
Bat First Wins = COUNTROWS(FILTER(Matches, Matches[Toss Winner] = Matches[Winner] && Matches[Toss Decision] = "Bat"))
Field First Wins = COUNTROWS(FILTER(Matches, Matches[Toss Winner] = Matches[Winner] && Matches[Toss Decision] = "Field"))

# Report Snapshot (Power BI DESKTOP)

<img width="1304" height="753" alt="Image" src="https://github.com/user-attachments/assets/4af07794-cb42-4f89-abde-fac190dedc57" />

## Insights

Team Performance -
India dominated with highest win counts.

Toss Impact -
Batting first yielded slightly higher win 58.33% in day-night matches.

Margins of Victory -
Avg win by 54 runs or 5 wickets.

Top Player-
Virat Kohli secured most Player of the Match awards(2).

Match Results -
A few rain-affected no-result games impacted standings.
