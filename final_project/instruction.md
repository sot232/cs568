
**California University of Management and Sciences** 

**ADVANCED SQL** 

**SUMMER 2025**

**FOR THE FINAL PROJECT (To be submitted and presented at the end of the 9th week. Grade 10 points)**

In this **final project** for the **Advanced SQL** course, you should demonstrate your  ability to:

* Design a schema,  
* Write complex queries,  
* Use views (regular and materialized),  
* Handle concurrency or transactions,  
* Apply performance techniques (like indexing or joins).

**Final Project: "Design and Query a Mini Data Warehouse"**

 **Project Overview:**

Students will design and implement a mini data warehouse for a fictional company or a company they intend to start or work at in the future  (e.g., an online bookstore, movie streaming platform, or retail store).

## **What you will deliver**

### 1\) Design & Data (Weeks 1–3)

* ER Diagram (OLTP) \+ 3NF explanation (brief notes per table: keys, FKs, purpose).  
* OLAP schema plan (fact table \+ dimension tables; say what one row in the fact table means).  
* Implementation SQL: CREATE TABLE \+ constraints (PKs, FKs, CHECKs/ENUMs).  
* Sample data: Mock/CSV/Kaggle.  
   Minimum: \~10 tables total across OLTP+OLAP; ≥1 FK per major table; ≥ 200 to 500 rows total (before aggregations), so queries are meaningful.

### 2\) Core Queries (Weeks 4–5, 8\)

* 10+ queries showing:

  * Multi-table JOINs (inner/left/right),

  * Aggregations (GROUP BY, HAVING),

  * Subqueries/CTEs (use `WITH` CTEs in MySQL 8+),

  * Functions (date, string, numeric—e.g., `DATE_ADD`, `UPPER`, `ROUND`, `CONCAT`).

### 3\) **Views & “Materialized” Views (Weeks 6 & 8\)**

* At least 2 or more regular views to simplify common reporting queries.

* (Optional) 1 “materialized” view in MySQL:

   Since MySQL has no native materialized views, simulate one using a table \+ a stored procedure (or event) to refresh it. This part is optional 

### 4\) **Transactions & Concurrency (Week 6 & 8\)**

* A stored procedure that uses `START TRANSACTION/COMMIT/ROLLBACK` with business rule checks and error handling (e.g., enroll student/place order with inventory checks).

* A brief concurrency demo: run two sessions (or simulate) to show how `SELECT ... FOR UPDATE` or transaction isolation prevents race conditions.

### 5\) **Performance (Week 7\)**

* Indexes: create at least 3 helpful indexes (PKs don’t count). Include one covering or composite index.

* Before/After evidence: use `EXPLAIN` and (optionally) timing to show impact. Add 1–2 optimized queries and explain why the index helps.

* (Optional) Discuss partitioning/sharding at a high level for your domain.

### **6\) Presentation (25 minutes)**

* Tell your design story (why your schema is structured this way).

* Show live demos: key queries, a view, the “materialized” view refresh, the transaction procedure with both commit and rollback, and one performance improvement.

* End with lessons learned as a group and “what you would improve next.”

---

## **Submission Package**

***Submit all deliverables in a Word document and prepare a PowerPoint presentation that covers all the areas.*** 

* /sql: All DDL/DML scripts (tables, constraints, views, procedures, test data).

* /docs: ERD (image/PDF), OLAP design notes, index report (before/after), transaction notes (what it protects, how to test), and materialized view refresh doc (what, when, how).

* /demo: Screenshots (before/after tables for transactions, EXPLAIN output, view results).

* README.md: How to run your project (order of scripts, needed MySQL version, any assumptions).

* A GitHub repository or all the code.


**N:B** Provide a business rationale for all the queries. Please refrain from submitting any query without a clear business and performance benefit behind it. Make all query outputs insightful for business intelligence and analytics.


Final Project Evaluation Rubric (10 points total)

| Criteria | Points | Key Focus Areas | Week Alignment |
| :---- | :---- | :---- | :---- |
| **Database Design** | 2 | ERD clarity, 3NF, meaningful FKs/constraints; | Weeks 1-3 |
| **Queries** | 3 | 10+ correct, non-trivial queries; JOINs/aggregations/subqueries/CTEs; use of string/date/numeric functions. | Weeks 4-5, 8 |
| **Views & Automation** | 2 |  2 regular views 2 stored procedure/trigger/cursor | Weeks 6-7, 8 |
| **Transactions & Concurrency** | 2 | Stored procedure with COMMIT/ROLLBACK and error handling; concurrency/race-condition explanation or demo. | Week 6, 8 |
| **Performance** | 2 | Good index choices; EXPLAIN evidence; at least one “before vs after” improvement. | Week 7 |
| **Presentation & Documentation** | 2 | Clear, organized, accurate; demo runs; code commented; lessons learned. | All weeks |
| **What You Learned**  | 2 | Each student to submit a one-page narrative  what he or she learned from the course (Individual submission only |  |

**Evaluation Criteria for Final Project (10 points):**

| Criteria | Points |
| :---- | :---- |
| Schema Design (normalized \+ logical) |  1 |
| Use of Views  |  2 |
| Query Complexity & Accuracy |  2 |
| Use of Transactions / Concurrency |  1 |
| Performance Optimization |  1 |
| Report / Documentation |  1 |
| Presentation / Code Organization |  2 |

**Good luck** 
