DB2数字计算——小数位精度保留

字段本身都是varchar类型，sum的结果在相除之前需要转换为double类型，不然相除就会自动截断位数

```sql

SELECT SUM(CONTRACT_AMOUNT*REAL_INTEREST_RATE)/SUM(CONTRACT_AMOUNT),
CAST((CAST(SUM(CONTRACT_AMOUNT*REAL_INTEREST_RATE) AS DOUBLE)/CAST(SUM(CONTRACT_AMOUNT) AS DOUBLE)) AS DECIMAL(10,4))
FROM BSTAMSCW00.T_DWD_FACT_CWZJ_STC_CONTRACT WHERE COMPANY_CODE='1013';
```

