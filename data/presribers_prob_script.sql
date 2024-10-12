
SELECT *
FROM drug;

SELECT *
FROM prescriber;

SELECT *
FROM prescription;

SELECT *
FROM overdose_deaths;

SELECT *
FROM population;

SELECT *
FROM cbsa;

SELECT *
FROM fips_county;

SELECT *
FROM zip_fips;


-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
/*NOTE:
- SUM of claims
- key: NPI
- Return: NPI, SUM of claims (DESC)
*/

--INITIAL ATTEMPT:
SELECT
	p1.npi
,	CONCAT(p1.nppes_provider_first_name, ' ',p1.nppes_provider_last_org_name)
,	SUM(p2.total_claim_count) AS sum_claims
FROM prescriber AS p1
	INNER JOIN prescription AS p2
		ON p1.npi = p2.npi
GROUP BY 
	p1.npi
,	2
ORDER BY 3 DESC;
--INITIAL ANS: 1881634483	"BRUCE PENDLEY"	99707

--ALT ANSWER:
SELECT DISTINCT npi
		,	SUM(total_claim_count) as total_claims
	FROM prescription
	GROUP BY npi
	ORDER BY total_claims DESC
	LIMIT 1;
    
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
/*NOTE:

*/
--INITIAL ATTEMPT:
SELECT
	p1.npi
,	sum(total_claim_count) AS sum_claims
,	CONCAT(p1.nppes_provider_first_name, ' ',p1.nppes_provider_last_org_name)
,	p1.specialty_description
FROM prescriber AS p1
	INNER JOIN prescription AS p2
		ON p1.npi = p2.npi
GROUP BY 
	p1.npi
,	CONCAT(p1.nppes_provider_first_name, ' ',p1.nppes_provider_last_org_name)
,	p1.specialty_description
ORDER BY sum_claims DESC;
--INITIAL ANS: "Family Practice"

--ALT ANSWER:
SELECT nppes_provider_first_name,nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS total_claim_count_over_all_drugs
FROM prescription
INNER JOIN prescriber
ON prescriber.npi=prescription.npi
GROUP BY nppes_provider_first_name,nppes_provider_last_org_name, specialty_description
ORDER BY total_claim_count_over_all_drugs DESC
-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?
/*NOTE:
- "totaled over all drugs means"... ?
*/
--INITIAL ATTEMPT:
SELECT
	SUM(p1.total_claim_count) AS sum_claims
,		p2.specialty_description
FROM prescription AS p1
	INNER JOIN prescriber AS p2
		ON p1.npi = p2.npi
GROUP BY
	p2.specialty_description
ORDER BY 
	sum_claims DESC
LIMIT 1;
--INITIAL ANS: "Family Practice" = 9752347

--     b. Which specialty had the most total number of claims for opioids?
/*NOTE:
*/

--INITIAL ATTEMPT:
SELECT 
	SUM(p1.total_claim_count) AS sum_claims
,	p2.specialty_description
,	d.opioid_drug_flag
FROM prescription AS p1
	INNER JOIN prescriber AS p2
		ON p1.npi = p2.npi 
	INNER JOIN drug AS d
		ON p1.drug_name = d.drug_name
WHERE d.opioid_drug_flag = 'Y'
GROUP BY 
	p2.specialty_description
,	d.opioid_drug_flag
ORDER BY sum_claims DESC;
--INITIAL ANS: 900845, "Nurse Practitioner"

--ALT ANS:
SELECT 
	p.specialty_description,
	SUM(total_claim_count) as total_sum
FROM prescriber as p
INNER JOIN prescription as pr
ON p.npi=PR.npi
INNER JOIN drug as d
ON pr.drug_name=d.drug_name
WHERE d.opioid_drug_flag = 'Y'
GROUP BY 1 
ORDER BY total_sum DESC;
--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
/*NOTE:

*/
--INITIAL ATTEMPT:
--INITIAL ANS:

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
/*NOTE:

*/
--INITIAL ATTEMPT:
--INITIAL ANS:

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?
/*NOTE:
- drug, prescription
*/

--INITIAL ATTEMPT:
-- SELECT
-- 	d.generic_name
-- ,	p.total_drug_cost::MONEY
-- FROM drug AS d
-- 	INNER JOIN prescription AS p
-- 		ON d.drug_name = p.drug_name
-- ORDER BY 
-- 	p.total_drug_cost::MONEY DESC;
-- --INITIAL ANS: "PIRFENIDONE" = $2,829,174.30 --missing sum(total_drug_cost)

--CORRECT ANS:
SELECT drug.generic_name
	, SUM(prescription.total_drug_cost) AS total_cost
FROM drug
INNER JOIN prescription
	ON drug.drug_name = prescription.drug_name
WHERE prescription.total_drug_cost IS NOT NULL
GROUP BY drug.generic_name
ORDER BY total_cost DESC
LIMIT 10;
--ANS: "INSULIN GLARGINE,HUM.REC.ANLOG"	104264066.35

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
/*NOTE:
- drug, prescription
- INNER JOIN drug_name
- total_drug_cost/total_day_supply
*/

--INITIAL ATTEMPT:
SELECT
	d.generic_name
,	ROUND(MAX(p.total_drug_cost/p.total_day_supply),2)::MONEY AS round_daily_cost
FROM drug AS d
	INNER JOIN prescription as p
		ON d.drug_name = p.drug_name
GROUP BY
	d.generic_name
ORDER BY
	round_daily_cost DESC;
--INITIAL ANS: "IMMUN GLOB G(IGG)/GLY/IGA OV50" = $7,141.11

--CORRECT ANS:
SELECT drug.generic_name
		,	(SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply)) :: MONEY as daily_drug_cost
	FROM prescription
		INNER JOIN drug
			USING (drug_name)
	GROUP BY drug.generic_name
	ORDER BY daily_drug_cost DESC
--ANS: "C1 ESTERASE INHIBITOR"	"$3,495.22"

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 
/*NOTE:
- drug
*/
--INITIAL ATTEMPT (CORRECT):
SELECT
	drug_name 
,	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'END AS drug_type
FROM drug;
--INITIAL ANS: **See return table

-- --CASE W/ COUNT:
-- SELECT
-- 	drug_name 
-- ,	COUNT(CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'END) AS opioid_count
-- ,	COUNT(CASE WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' END) AS antibiotic_count
-- ,	COUNT(CASE WHEN opioid_drug_flag <> 'Y' AND antibiotic_drug_flag <> 'Y' THEN 'neither' END) AS neither_count
-- FROM drug
-- GROUP BY drug_name;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
/*NOTE:
- drug, prescription --> join on drug_name
- return: total
- double check join: w/ SELECT * and JOIN syntax
*/
--INITIAL ATTEMPT:
SELECT
	d.drug_name
,	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		END AS drug_type
,	p.total_drug_cost::MONEY
FROM drug AS d
	INNER JOIN prescription AS p
		ON d.drug_name = p.drug_name
-- WHERE CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
-- 		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
-- 		END IS NOT NULL
ORDER BY p.total_drug_cost DESC;
--INITIAL ANS: opioid = $365,580.05 = OPANA ER

--CORRECT ANS:
SELECT drug_type, SUM(total_drug_cost)::MONEY AS total_cost 
FROM 
	(SELECT drug.drug_name ,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
	END AS drug_type , total_drug_cost 
	FROM drug AS drug
	INNER JOIN prescription
	ON drug.drug_name = prescription.drug_name ) AS drug_cost 
WHERE drug_type IN ('opioid','antibiotic')
GROUP BY drug_type;
--ANS: "opioid"	= $105,080,626.37

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
/*NOTE:
- cbsa, fips_county 
- fipscounty JOIN
- COUNT
*/
--INITIAL ATTEMPT:
SELECT cbsaname
FROM cbsa AS c
	INNER JOIN fips_county AS f
		ON c.fipscounty = f.fipscounty
WHERE state LIKE '%TN%';
--INITIAL ANS: 42

--Finding TN using cbsaname, why using state is better to answer 5a:
SELECT *
FROM cbsa
WHERE cbsaname iLIKE '%TN%'
	AND cbsaname NOT IN(SELECT cbsaname
FROM cbsa AS c
	INNER JOIN fips_county AS f
		ON c.fipscounty = f.fipscounty
WHERE state LIKE '%TN%')

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
/*NOTE:
- cbsa, population --> JOIN fipscounty
- cbsaname, population
- MAX, MIN? Probs SUM bc "combined pop"
- can I use a subquery to return largest and smallest 
*/

--INITIAL ATTEMPT (not filtered to smallest and largest):
SELECT
	c.cbsaname
, 	SUM(p.population) AS combined_pop
FROM cbsa AS c
	INNER JOIN population AS p
		ON c.fipscounty = p.fipscounty
GROUP BY 1
ORDER BY 2 DESC;
--INITIAL ANS:  Largest = "Nashville-Davidson-Murfreesboro-Franklin, TN" = 1830410, Smallest = "Morristown, TN" = 116352

--ALT ANS (UNION):
(
SELECT cbsaname, SUM(population) AS total_population, 'largest' as flag
FROM cbsa 
INNER JOIN population
USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_population DESC
limit 1
)
UNION
(
SELECT cbsaname, SUM(population) AS total_population, 'smallest' as flag
FROM cbsa 
INNER JOIN population
USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_population 
limit 1
) 
order by total_population desc;

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
/*NOTE:
- not included --> subquery (antijoin?) or set operation (EXCEPT)?
- fips_county, population, cbsa
- JOIN ON fipscounty
- return: county, population
*/
--INITIAL ATTEMPT:
SELECT
	f.county
,	p.population
FROM fips_county AS f
	INNER JOIN population AS p
		ON f.fipscounty = p.fipscounty
WHERE f.fipscounty NOT IN
	(SELECT fipscounty 
	FROM cbsa)
ORDER BY 
	p.population DESC;
--INITIAL ANS: "SEVIER", 95523

--ALT ANS (EXCEPT + Subquery):
SELECT f.county, SUM(p.population) as combined_population
FROM fips_county AS f
INNER JOIN population AS p 
	ON f.fipscounty = p.fipscounty
WHERE f.fipscounty IN
		--Subquery to return TN fipscounty which are not included in CBSA
		(SELECT fipscounty FROM fips_county --WHERE STATE = 'TN' --fips_county table has 96 records for TN
		EXCEPT
		SELECT fipscounty FROM cbsa) --Total 54 fipscounty are not present in CBSA
GROUP BY f.county
ORDER BY combined_population desc
LIMIT 1
/* Answer = "SEVIER" county with 95523 population is the largest county in terms of population, which is not included in a CBSA*/

--ALT ANS (2 JOINS):
SELECT fc.county,
	   p.population
FROM population  AS p
	INNER JOIN fips_county AS fc
	ON p.fipscounty = fc.fipscounty
	LEFT JOIN cbsa
	ON fc.fipscounty = cbsa.fipscounty 
WHERE cbsa.cbsa IS NULL
ORDER BY p.population DESc

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
/*NOTE:
- prescription, drug
- filter for >= 3000
- return: drug_name, total_claim_count
*/
--INITIAL ATTEMPT:
SELECT
	drug_name
,	total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;
--INITIAL ANS: 9 return records, "OXYCODONE HCL" at 4538

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
/*NOTE:
- build off 6a query
- CASE statement: opioid flag
*/
--INITIAL ATTEMPT:
SELECT
	p.drug_name
,	total_claim_count
,	CASE WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		WHEN opioid_drug_flag = 'N' THEN 'Not Opioid'
		END AS opioid_filter
FROM prescription AS p
	INNER JOIN drug AS d
		ON p.drug_name = d.drug_name
WHERE total_claim_count >= 3000;
--INITIAL ANS: 2 return records: "OXYCODONE HCL" = 4538 = "Opioid", "HYDROCODONE-ACETAMINOPHEN"= 3376= "Opioid"

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
/*NOTE:
- new column: concat(first, last)
*/
--INITIAL ATTEMPT:
SELECT
	p1.drug_name
,	total_claim_count
,	CONCAT(nppes_provider_first_name, ' ', nppes_provider_last_org_name) AS first_lastname
,	CASE WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		WHEN opioid_drug_flag = 'N' THEN 'Not Opioid'
		END AS opioid_filter
FROM prescription AS p1
	INNER JOIN drug AS d
		ON p1.drug_name = d.drug_name
	INNER JOIN prescriber AS p2
		ON p1.npi = p2.npi
WHERE total_claim_count >= 3000;
--INITIAL ANS:9 return records*

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
/*NOTE:
- prescriber, drug
- filter opioid_drug_flag = 'Y', specialty_desc, nppes_provider_city
- crossjoin 
*/
--INITIAL ATTEMPT:
SELECT
	p.npi
,	drug_name
FROM prescriber AS p
	CROSS JOIN drug AS d
WHERE opioid_drug_flag = 'Y'
	AND nppes_provider_city = 'NASHVILLE'
	AND specialty_description = 'Pain Management'
ORDER BY 
	p.npi
,	drug_name;
--INITIAL ANS: see return table*

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
 /*NOTE:

*/
--INITIAL ATTEMPT:
SELECT
	p.npi
,	d.drug_name
, 	SUM(rx.total_claim_count) AS sum_claims
FROM prescriber AS p
	CROSS JOIN drug AS d
	LEFT JOIN prescription AS rx
		ON d.drug_name = rx.drug_name
WHERE opioid_drug_flag = 'Y'
	AND nppes_provider_city = 'NASHVILLE'
	AND specialty_description = 'Pain Management'
GROUP BY p.npi, d.drug_name
ORDER BY p.npi;
--INITIAL ANS:   

--ALT ANS:
SELECT prescriber.npi
		,	drug.drug_name
		,	SUM(prescription.total_claim_count) AS sum_total_claims
	FROM prescriber
		CROSS JOIN drug
		LEFT JOIN prescription
			USING (drug_name)
	WHERE prescriber.specialty_description = 'Pain Management'
		AND prescriber.nppes_provider_city = 'NASHVILLE'
		AND drug.opioid_drug_flag = 'Y'
	GROUP BY prescriber.npi
		,	drug.drug_name
	ORDER BY prescriber.npi;

--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
/*NOTE:

*/
--INITIAL ATTEMPT:
SELECT
	p.npi
,	drug_name
,	total_claim_count
FROM prescriber AS p
	CROSS JOIN drug AS d
WHERE opioid_drug_flag = 'Y'
	AND nppes_provider_city = 'NASHVILLE'
	AND specialty_description = 'Pain Management';
--INITIAL ANS:

--CORRECT ANS:
SELECT prescriber.npi
		,	drug.drug_name
		,	COALESCE(SUM(prescription.total_claim_count), 0) AS sum_total_claims
	FROM prescriber
		CROSS JOIN drug
		LEFT JOIN prescription
			USING (drug_name)
	WHERE prescriber.specialty_description = 'Pain Management'
		AND prescriber.nppes_provider_city = 'NASHVILLE'
		AND drug.opioid_drug_flag = 'Y'
	GROUP BY prescriber.npi
		,	drug.drug_name
	ORDER BY prescriber.npi;