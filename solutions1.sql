
--1)Show the percentage of wins of each bidder in the order of highest to lowest percentage.
--method 1 neglecting the cancelled and bid values in bid status
SELECT x.bidder_id,y.bidder_name,x.winning_percentage FROM
(SELECT bidder_id,
(COUNT(*) FILTER(WHERE bid_status='Won')*100/COUNT(*) FILTER(WHERE bid_status='Won' OR bid_status='Lost')) 
AS winning_percentage
FROM ipl.Bidding_Details
GROUP BY bidder_id) AS x
INNER JOIN ipl.Bidder_Details AS y
ON x.bidder_id=y.bidder_id
ORDER BY x.winning_percentage DESC;

--method 2 considering all the values in bid status
SELECT x.bidder_id,y.bidder_name,x.winning_percentage FROM
(SELECT bidder_id,
(COUNT(*) FILTER(WHERE bid_status='Won')*100/COUNT(*)) 
AS winning_percentage
FROM ipl.Bidding_Details
GROUP BY bidder_id) AS x
INNER JOIN ipl.Bidder_Details AS y
ON x.bidder_id=y.bidder_id
ORDER BY x.winning_percentage DESC;



--2)Which teams have got the highest and the lowest no. of bids?

--method 1 considering all the values in bid status
SELECT y.team_id,y.team_name,x.number_of_bids FROM 
((SELECT bid_team,COUNT(bid_team) AS number_of_bids
FROM ipl.Bidding_Details
GROUP BY bid_team
ORDER BY number_of_bids DESC
LIMIT 1)
UNION
(SELECT bid_team,COUNT(bid_team) AS number_of_bids
FROM ipl.Bidding_Details
GROUP BY bid_team
ORDER BY number_of_bids 
LIMIT 1)) AS x
INNER JOIN ipl.Team AS y
ON x.bid_team=y.team_id;

--method2 neglecting the cancelled values in bid status
SELECT y.team_id,y.team_name,x.number_of_bids FROM 
((SELECT bid_team,COUNT(case when bid_status in ('Won','Lost','Bid') then 1 end) AS number_of_bids
FROM ipl.Bidding_Details
GROUP BY bid_team
ORDER BY number_of_bids DESC
LIMIT 1)
UNION
(SELECT bid_team,COUNT(case when bid_status in ('Won','Lost','Bid') then 1 end) AS number_of_bids
FROM ipl.Bidding_Details
GROUP BY bid_team
ORDER BY number_of_bids 
LIMIT 1)) AS x
INNER JOIN ipl.Team AS y
ON x.bid_team=y.team_id;


--3)In a given stadium, what is the percentage of wins by a team which has won the toss?

 WITH my_cte AS
(SELECT x.match_id,x.toss_winner,x.match_winner,x.stadium_id,y.stadium_name FROM
(SELECT m.match_id,m.toss_winner,m.match_winner,ms.stadium_id
FROM ipl.match AS m
INNER JOIN ipl.match_schedule AS ms
ON m.match_id=ms.match_id) AS x
INNER JOIN ipl.stadium AS y
ON x.stadium_id=y.stadium_id)
SELECT stadium_id,stadium_name,
(COUNT(*) FILTER(WHERE toss_winner=match_winner)*100/COUNT(*))
AS "winning percentage of teams who won toss"
FROM my_cte
GROUP BY stadium_id,stadium_name
ORDER BY "winning percentage of teams who won toss" DESC;

--4)What is the total no. of bids placed on the team that has won the highest no. of matches?

SELECT bid_team,COUNT(bid_team) AS "Total number of bids"
FROM ipl.bidding_details
GROUP BY bid_team
HAVING bid_team=
(SELECT winning_teamid FROM
(SELECT winning_teamid,COUNT(winning_teamid) AS total_matches_won
FROM
(SELECT *,
CASE
WHEN match_winner=1 THEN team_id1
WHEN match_winner=2 THEN team_id2
END AS winning_teamid
FROM ipl.match)
GROUP BY winning_teamid
ORDER BY total_matches_won DESC
LIMIT 1));




/*5)From the current team standings, if a bidder places a bid on which of the teams, there is a
possibility of he winning the highest no. of points – in simple words, identify the team which
has the highest jump in its total points (in terms of percentage) from the previous year to current
year.*/

SELECT
	t.team_name,
    i.team_id,
    (SUM(CASE WHEN tournament_id = 2018 THEN TOTAL_POINTS ELSE 0 END) -
    SUM(CASE WHEN tournament_id = 2017 THEN TOTAL_POINTS ELSE 0 END))*100/SUM(CASE WHEN tournament_id = 2017 THEN TOTAL_POINTS ELSE 0 END) AS percentage_jump
FROM
    ipl.team_standings i, ipl.team t
where t.team_id= i.team_id
GROUP BY
    i.team_id, t.team_name
order by percentage_jump desc
LIMIT 1;





















