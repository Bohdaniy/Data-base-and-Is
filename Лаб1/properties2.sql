INSERT INTO
	CAR (NAME, DATE, VIN)
VALUES
	(
		'BMW M5 Competition',
		'25.01.2025',
		'WBALSYCULR5TA4365'
	),
	('Audi A4', '29.11.2024', 'WAUGX68UXXMMM9667');

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

UPDATE REPAIR
SET
	REPAIRS = 'Заміна масляного фільтру, заміна масла + заміна повітряного фільтру'
WHERE
	REPAIR_ID = 2;

DELETE FROM CLIENT
WHERE
	CLIENT_ID = 1;