INSERT INTO
	CAR (NAME, DATE, MODEL)
VALUES
	('BMW', '25.01.2025', 'BMW M5 Competition'),
	('Audi', '29.11.2024', 'Audi A4');

INSERT INTO
	CLIENT (NAME, AGE, COUNTRY)
VALUES
	('Petro Oleksiovich', '29', 'UA'),
	('Karasiovich Molbertovich', '21', 'PL');

INSERT INTO
	REPAIR (CAR_ID, CLIENT_ID, REPAIRS)
VALUES
	(
		'1',
		'1',
		'Загорівся чек на приборці, потекло масло та прочистка радіатора'
	),
	(
		'2',
		'2',
		'Заміна масляного фільтру, заміна масла'
	);

SELECT
	*
FROM
	CAR;

SELECT
	*
FROM
	CLIENT;

SELECT
	*
FROM
	REPAIR;