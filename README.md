# 🚀 Autorizame - Sistema de Autorización con Blockchain e IPFS

Autorizame es una solución integral para la gestión de autorizaciones en el reparto de pedidos utilizando tecnologías de **Blockchain** y almacenamiento descentralizado (**IPFS**). El sistema asegura que solo personas autorizadas puedan recibir pedidos, mediante el uso de **NFTs** que actúan como credenciales verificables.

## 🏗️ Arquitectura del Proyecto

El proyecto está compuesto por tres componentes principales que interactúan entre sí:

### 1. 🍃 Backend Spring Boot (`Autorizame-api`)
- **Tecnología:** Java 17, Spring Boot, Spring Data JPA, PostgreSQL.
- **Función:** Orquestador principal de la lógica de negocio. Gestiona la persistencia en base de datos y coordina las llamadas a los microservicios de Blockchain e IPFS.
- **Base de Datos:** PostgreSQL (alojada en Supabase).

### 2. 📦 Wrapper IPFS/Pinata (`ms_wrapper_ipfs`)
- **Tecnología:** Node.js, Express, Pinata SDK.
- **Función:** Gestiona la subida y recuperación de metadatos de los pedidos a IPFS a través de Pinata.

### 3. ⛓️ Wrapper Smart Contract (`ms_wrapper_sc`)
- **Tecnología:** Node.js, Express, Ethers.js.
- **Función:** Interactúa con un Smart Contract desplegado en Sepolia para el minteo y transferencia de NFTs de autorización.

---

## 🛠️ Tecnologías Utilizadas

- **Backend:** Spring Boot (Java).
- **Microservicios:** Node.js & Express.
- **Persistencia:** JPA / Hibernate & PostgreSQL.
- **Web3:** Ethers.js, Sepolia Testnet, ERC-721.
- **Almacenamiento:** IPFS via Pinata.
- **API Documentation:** Swagger / OpenAPI.

---

## 🚀 Instalación y Uso

### 0. Requisitos Previos
- Node.js y npm instalados.
- Java 17+ y Maven instalados.
- Cuenta en Pinata y Wallet de Ethereum (Sepolia).

### 1. Configuración de Microservicios
Debes configurar los archivos `.env` en cada carpeta de microservicio:

#### En `ms_wrapper_ipfs`:
```env
PINATA_JWT=tu_jwt_aqui
PINATA_GATEWAY=tu_gateway_aqui
PORT=8081
```

#### En `ms_wrapper_sc`:
```env
RPC_URL=tu_rpc_url_sepolia
CONTRACT_ADDRESS=direccion_del_contrato
OWNER_PRIVATE_KEY=tu_clave_privada
PORT=8082
```

### 2. Ejecución
Ejecuta cada servicio en una terminal diferente siguiendo este orden:

1. **IPFS Wrapper:** `cd ms_wrapper_ipfs && npm start`
2. **SC Wrapper:** `cd ms_wrapper_sc && npm start`
3. **Spring Backend:** `cd Autorizame-api && ./mvnw spring-boot:run`

---

## 📡 Endpoints Principales (Spring Boot)

| Método | Endpoint | Descripción |
| :--- | :--- | :--- |
| `POST` | `/api/v1/pedidos` | Crea un pedido, sube metadata a IPFS y minta el NFT. |
| `GET` | `/api/v1/pedidos` | Lista todos los pedidos con sus datos de Blockchain. |
| `GET` | `/api/v1/pedidos/blockchain/metadata/{cid}` | Recupera el JSON de IPFS. |
| `POST` | `/api/v1/pedidos/{id}/transferir` | Transfiere el NFT al autorizado. |

---

## 📈 Flujo de Trabajo
1. El sistema crea un pedido y genera un metadata JSON.
2. El metadata se sube a **IPFS** obteniendo un **CID**.
3. Se minta un **NFT** en la Blockchain que contiene ese CID en su `tokenURI`.
4. Los datos de la transacción (`CID`, `txHash`, `tokenId`) se persisten en **PostgreSQL**.
5. Al realizar la entrega, el NFT es transferido a la wallet del autorizado.

---

## 👥 Autores
- **Iván Ramírez** - [GitHub](https://github.com/ivanramirez2)
