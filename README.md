# E-Commerce Sales & Customer Analytics

An end-to-end portfolio project exploring sales performance, product
profitability, customer behavior, and returns using Excel, Power Query,
PostgreSQL, Power BI, and DAX.

## Business Problem

An e-commerce business needs to understand what drives revenue and
profit, which products and categories perform well, how customer
segments contribute, and where product returns warrant investigation.

Key questions: - How are revenue, profit, and margin performing? - Which
categories, products, regions, and channels contribute most? - Which
products have high sales but weaker profitability? - How do customer
segments differ in sales and profit? - How do returns vary by category
and shipping method?

## Objectives

1.  Evaluate sales and profitability KPIs.
2.  Compare product and category performance.
3.  Explore customer and segment-level patterns.
4.  Analyse returns by category, shipping method, and reason.
5.  Communicate findings through dashboards and actionable
    recommendations.

## Tools

-   **Excel / Power Query:** data inspection, cleaning, and validation.
-   **PostgreSQL / SQL:** business-focused queries and analysis.
-   **Power BI:** interactive dashboards.
-   **DAX:** measures and KPIs.

## Workflow

1.  Inspected the dataset structure, fields, and data types.
2.  Removed 45 duplicate rows and reviewed anomalies, including
    unusually high discounts, unusual ages, negative quantities, and
    sales inconsistencies.
3.  Kept business-related blanks where appropriate and investigated
    questionable records instead of automatically deleting every unusual
    value.
4.  Used SQL to analyse sales, products, profitability, customers, and
    returns.
5.  Developed KPIs and organised the results into three Power BI
    dashboard pages.
6.  Summarised findings and proposed business recommendations.

## Dashboard Pages

### 1. Executive Sales Overview

Includes revenue, profit, orders, customers, average order value, profit
margin, monthly trends, regional performance, sales channels, and
category results.

![Executive Sales Overview](Screenshots/Dashboard%20Image%201.png)


### 2. Product and Profitability Analysis

Includes top products by revenue and profit, top/bottom products,
revenue-versus-profit comparisons, and category margins.

![Product and Profitability Analysis](Screenshots/Dashboard%20Image%202.png)


### 3. Customer and Returns Analysis

Includes customer metrics, return-related KPIs, returns by category and
shipping method, returned sales by category, customer/segment
performance, and return reasons.

![Customer and Returns Analysis](Screenshots/Dashboard%20Image%203.png)

## Key Findings

Figures below reflect the project's analysis and metric definitions.

-   **Revenue:** approximately 8.23M.
-   **Profit:** approximately 1.65M.
-   **Profit margin:** approximately 19.98%.
-   **Electronics revenue:** approximately 4.9M.
-   **Online-channel revenue:** approximately 3.11M.
-   **Appliances profit margin:** approximately 22.01%.
-   **Consumer segment:** led the analysed segments in sales and profit.
-   **Top product by revenue:** AeroBook 14 Laptop.
-   **Top product by profit:** Probook 16 Laptop.
-   **Return rate:** approximately 12.64% under the project's
    calculation.
-   **Returned sales:** approximately 828.30K under the project's metric
    definition.
-   **Next Day shipping return rate:** approximately 11.70%.

These are observed patterns, not proof of causation.

## Business Recommendations

1.  **Review low-margin products:** investigate pricing, discounts,
    product costs, and fulfilment expenses.
2.  **Learn from stronger categories:** examine product mix and
    commercial practices behind higher margins before making expansion
    decisions.
3.  **Investigate return patterns:** compare return reasons, categories,
    product condition, and shipping methods.
4.  **Measure the financial effect of returns properly:** reconcile
    returns with refunds, revenue reversals, product costs, and handling
    expenses.
5.  **Use customer segments thoughtfully:** test targeted retention,
    cross-sell, and service initiatives, then measure outcomes.
6.  **Monitor KPIs over time:** track revenue, profit, margin, and
    returns consistently.

## Definitions and Limitations

-   Returned sales are **not automatically equivalent to refunds or lost
    profit**; here, the metric represents sales value associated with
    records flagged as returned.
-   The return-rate result depends on the calculation grain. If the
    return flag is at line-item level, a distinct-order calculation may
    not represent a true order-level return rate.
-   The direct impact of returns on profit was not fully quantified
    because refunds/revenue reversals, costs, and handling expenses need
    to be reconciled.
-   Unusual data values should be checked against source definitions
    before being corrected or excluded.
-   Associations in the data do not establish causation.
-   Results apply to this dataset and its covered period, not
    necessarily to every e-commerce business.


---

**Project:** E-Commerce Sales & Customer Analytics  
**Tools:** Excel, Power Query, PostgreSQL, Power BI, DAX