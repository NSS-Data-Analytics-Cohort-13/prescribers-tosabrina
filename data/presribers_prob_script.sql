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
,	MAX(p2.total_claim_count) AS max_claims
FROM prescriber AS p1
	INNER JOIN prescription AS p2
		ON p1.npi = p2.npi
GROUP BY 1, 2
ORDER BY 3 DESC;
--INITIAL ANS: npi = 1912011792, "DAVID COFFEY", 4538 claims
    
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
/*NOTE:

*/
--INITIAL ATTEMPT:
SELECT
	p1.npi
,	MAX(total_claim_count) AS MAX_claims
,	CONCAT(p1.nppes_provider_first_name, ' ',p1.nppes_provider_last_org_name)
,	p1.specialty_description
FROM prescriber AS p1
	INNER JOIN prescription AS p2
		ON p1.npi = p2.npi
GROUP BY 
	p1.npi
,	CONCAT(p1.nppes_provider_first_name, ' ',p1.nppes_provider_last_org_name)
,	p1.specialty_description
ORDER BY MAX_claims DESC;
--INITIAL ANS: "Family Practice"

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
SELECT
	d.generic_name
,	p.total_drug_cost::MONEY
FROM drug AS d
	INNER JOIN prescription AS p
		ON d.drug_name = p.drug_name
ORDER BY 
	p.total_drug_cost::MONEY DESC;
--INITIAL ANS: "PIRFENIDONE" = $2,829,174.30

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

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 
/*NOTE:
- drug
*/
--INITIAL ATTEMPT:
SELECT
	drug_name 
,	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'END AS drug_type
FROM drug;
--INITIAL ANS: **See return table

--CASE W/ COUNT:
SELECT
	drug_name 
,	COUNT(CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'END) AS opioid_count
,	COUNT(CASE WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' END) AS antibiotic_count
,	COUNT(CASE WHEN opioid_drug_flag <> 'Y' AND antibiotic_drug_flag <> 'Y' THEN 'neither' END) AS neither_count
FROM drug
GROUP BY drug_name;

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
WHERE CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		END IS NOT NULL
ORDER BY p.total_drug_cost DESC;
--INITIAL ANS: opioid = $365,580.05 = OPANA ER

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
/*NOTE:
- cbsa, fips_county 
- fipscounty JOIN
- COUNT
- ILIKE '%TN'
- 55 = correct
*/
--INITIAL ATTEMPT:
SELECT COUNT(*)
FROM cbsa AS c
	INNER JOIN fips_county AS f
		ON c.fipscounty = f.fipscounty
WHERE cbsaname ILIKE '%TN';
--INITIAL ANS: 33

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
/*NOTE:
- cbsa, population --> JOIN fipscounty
- cbsaname, population
- MAX, MIN?
- can I use a subquery to return 
*/

--INITIAL ATTEMPT:
SELECT
	cbsaname
,	population
-- ,	MIN(population) as min_pop
-- ,	MAX(population) AS max_pop
FROM cbsa AS c
	INNER JOIN population AS pop
		ON c.fipscounty = pop.fipscounty
-- GROUP BY cbsaname
ORDER BY 1, 2 DESC;
--INITIAL ANS: Largest = "Chattanooga, TN-GA" and 354589, Smallest = "Nashville-Davidson-Murfreesboro-Franklin, TN", 8773

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
/*NOTE:
- not included, 
*/
--INITIAL ATTEMPT:
--INITIAL ANS:
-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
/*NOTE:

*/
--INITIAL ATTEMPT:
--INITIAL ANS:
--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
/*NOTE:

*/
--INITIAL ATTEMPT:
--INITIAL ANS:
--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
/*NOTE:

*/
--INITIAL ATTEMPT:
--INITIAL ANS:
-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
/*NOTE:

*/
--INITIAL ATTEMPT:

--INITIAL ANS:
--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
 /*NOTE:

*/
--INITIAL ATTEMPT:

--INITIAL ANS:   
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
/*NOTE:

*/
--INITIAL ATTEMPT:
--INITIAL ANS: