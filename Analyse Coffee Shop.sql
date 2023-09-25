-- Quels sont les magasins (sales_outlets) qui ont atteint ou dépassé leurs objectifs de vente (total_goal) pour un mois donné (year_month) ?

SELECT sr.sales_outlet_id, SUM(sr.quantity) AS total_quantity, st.total_goal
FROM sales_reciepts AS sr
INNER JOIN `sales targets` AS st ON st.sales_outlet_id = sr.sales_outlet_id
GROUP BY sr.sales_outlet_id, st.total_goal
HAVING total_quantity > st.total_goal;

-- Y a-t-il une corrélation entre la superficie du magasin (store_square_feet) et ses performances de vente (total_goal) ?
SELECT so.sales_outlet_id, so.store_square_feet, st.total_goal
FROM sales_outlet AS so
INNER JOIN `sales targets` AS st ON so.sales_outlet_id = st.sales_outlet_id;

-- Quels sont les membres de notre programme de fidélité (loyalty_card_number) les plus actifs en termes de fréquence d'achat et de montant dépensé ?
SELECT
    c.customer_id,
    c.`customer_first-name`,
    COUNT(s.transaction_id) AS nombre_achats,
    SUM(s.line_item_amount) AS montant_total_depense
FROM
    sales_reciepts as s
INNER JOIN
    customer as c
ON
    s.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.`customer_first-name`,
    c.`customer_first-name`
ORDER BY
    montant_total_depense DESC, nombre_achats DESC;
    
-- Quelle est la répartition des ventes par catégorie de produits (product_category) au fil du temps et comment cela évolue-t-il ?
SELECT sum(pi.quantity_sold) AS quantitysold, pi.transaction_date, p.product_category
FROM `pastry inventory` AS pi
INNER JOIN product AS p ON pi.product_id = p.product_id
GROUP BY pi.transaction_date, p.product_category
ORDER BY quantitysold DESC;

-- Quel est l'impact des nouvelles introductions de produits (new_product_yn) sur les ventes et la rentabilité ?
-- : Voir les nouveaux produits
select product, new_product_yn
from product
where new_product_yn = "Y";
-- : Mesurer l'impact
SELECT p.new_product_yn,
    SUM(pi.quantity_sold) AS total_quantity_sold,
    SUM(pi.quantity_sold * (p.current_retail_price - p.current_wholesale_price)) AS total_profit
FROM `pastry inventory` AS pi
INNER JOIN product AS p ON p.product_id = pi.product_id
where p.new_product_yn = "Y";


-- Quelle est la performance des différents catégories de produits (product_group) en termes de marge bénéficiaire et de quantité vendue ?
SELECT
    p.product_category,
    SUM(pi.quantity_sold) AS total_quantity_sold,
    SUM(pi.quantity_sold * (p.current_retail_price - p.current_wholesale_price)) AS total_profit
FROM `pastry inventory` AS pi
INNER JOIN product AS p ON pi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY total_profit DESC; -- : Tri par marge bénéficiaire décroissante

-- Comment varie la performance des magasins en fonction de leur emplacement géographique (store_city, store_state_province) ?
SELECT
    store_city,
    store_state_province,
    COUNT(DISTINCT subquery.sales_outlet_id) AS nombre_de_magasins,
    SUM(subquery.total_goal) AS objectif_total,
    SUM(subquery.total_quantity) AS quantite_totale_vendue,
    AVG(subquery.total_quantity) AS quantite_moyenne_vendue
FROM
(
    SELECT
        sr.sales_outlet_id,
        so.store_city,
        so.store_state_province,
        st.total_goal,
        SUM(sr.quantity) AS total_quantity
    FROM sales_reciepts AS sr
    INNER JOIN sales_outlet AS so ON so.sales_outlet_id = sr.sales_outlet_id
    INNER JOIN `sales targets` AS st ON st.sales_outlet_id = sr.sales_outlet_id
    GROUP BY sr.sales_outlet_id, so.store_city, so.store_state_province, st.total_goal
) AS subquery
GROUP BY store_city, store_state_province
LIMIT 0, 10000;

-- Existe-t-il une tendance générale de l'évolution des ventes au fil des années (year_month) et comment cette tendance varie-t-elle par catégorie de produits ?
SELECT p.product_category, SUM(pi.quantity_sold) AS total_quantity_sold, pi.transaction_date
FROM `pastry inventory` AS pi
INNER JOIN product as p ON p.product_id = pi.product_id
GROUP BY product_category
ORDER BY product_category;

SELECT p.product_category, SUM(pi.quantity_sold) AS total_quantity_sold
FROM `pastry inventory` AS pi
INNER JOIN product AS p ON p.product_id = pi.product_id
GROUP BY p.product_category
ORDER BY p.product_category DESC
LIMIT 0, 10000;

-- Quels sont les produits les plus vendus (quantity_sold) et ceux qui ont le taux de gaspillage le plus élevé (% waste) ?
SELECT 
    product_id,
    MAX(quantity_sold) AS max_quantity_sold,
    MAX(`% waste`) AS max_waste_rate
FROM `pastry inventory`
GROUP BY product_id
ORDER BY max_quantity_sold DESC, max_waste_rate DESC
LIMIT 10; -- Limitez les résultats aux 10 premiers produits

-- Y a-t-il une relation entre l'âge des clients (calculé à partir de leur année de naissance - birth_year) et leurs habitudes d'achat (fréquence, montant) ?
SELECT
    birth_year AS birth_year,
    COUNT(sr.customer_id) AS nombre_achats,
    CAST(SUM(sr.line_item_amount) AS DECIMAL(10, 2)) AS montant_total_achats
FROM
    sales_reciepts AS sr
INNER JOIN
    customer AS c
    ON sr.customer_id = c.customer_id
GROUP BY
    birth_year
ORDER BY
   nombre_achats DESC;

-- Quel est le rendement individuel des membres du personnel en fonction de leurs objectifs de vente (beans_goal, beverage_goal, food_goal, merchandise_goal) ?
select s.staff_id, s.first_name, s.last_name, st.beans_goal, st.beverage_goal, st.food_goal, st.`merchandise _goal`, st.total_goal, 
CAST(sum(sr.quantity * sr.unit_price) AS DECIMAL(10, 2)) as CA
from`sales targets` AS st
inner join sales_reciepts as sr on sr.sales_outlet_id = st.sales_outlet_id
inner join staff as s on s.staff_id = sr.staff_id
group by staff_id, first_name, last_name, beans_goal, beverage_goal, food_goal, `merchandise _goal`, total_goal
order by CA ASC;

-- Y a-t-il une corrélation entre l'ancienneté des membres du personnel (start_date) et leurs performances en termes de réalisation des objectifs de vente ?
select s.start_date, s.staff_id, s.first_name, s.last_name, st.beans_goal, st.beverage_goal, st.food_goal, st.`merchandise _goal`, st.total_goal,
CAST(sum(sr.quantity * sr.unit_price) AS DECIMAL(10, 2)) as CA
from `sales targets` as st
inner join sales_reciepts as sr on sr.sales_outlet_id = st.sales_outlet_id
inner join staff0 as s on s.staff_id = sr.staff_id
group by s.staff_id, start_date, first_name, last_name, beans_goal, beverage_goal, food_goal, `merchandise _goal`, total_goal
order by CA DESC;


-- Quels types de produits (beans, beverages, food, merchandise) sont mieux vendus par chaque membre du personnel ?
select sr.staff_id, p.product_group, 
CAST(sum(sr.quantity * sr.unit_price) AS DECIMAL(10, 2)) as CA
from sales_reciepts as sr
inner join product as p on p.product_id = sr.product_id
GROUP BY sr.staff_id, p.product_group
order by CA DESC;

-- Existe-t-il une différence de performance entre les différents types de points de vente (sales_outlet_type) en termes de réalisation des objectifs ?
SELECT
    sales_outlet_id,
    sales_outlet_type,
    CAST(AVG(total_quantity) AS DECIMAL(10, 2)) AS average_quantity,
    CAST(AVG(total_goal) AS DECIMAL(10, 2)) AS average_goal
FROM (
    SELECT
        sr.sales_outlet_id,
        so.sales_outlet_type,
        SUM(sr.quantity) AS total_quantity,
        st.total_goal
    FROM sales_reciepts AS sr
    INNER JOIN `sales targets` AS st ON st.sales_outlet_id = sr.sales_outlet_id
    INNER JOIN sales_outlet AS so ON st.sales_outlet_id = so.sales_outlet_id
    GROUP BY sr.sales_outlet_id, so.sales_outlet_type, st.total_goal
) AS subquery
GROUP BY sales_outlet_id, sales_outlet_type
ORDER BY average_goal DESC;

-- Comment la superficie du magasin (store_square_feet) affecte-t-elle les performances du personnel en termes de réalisation des objectifs ?
 
SELECT
    so.sales_outlet_id,
    so.store_square_feet,
	CAST(sum(sr.quantity) AS DECIMAL(10, 2)) AS total_quantity
FROM sales_reciepts AS sr
INNER JOIN sales_outlet AS so ON sr.sales_outlet_id = so.sales_outlet_id
GROUP BY so.sales_outlet_id, so.store_square_feet
order by store_square_feet DESC; 