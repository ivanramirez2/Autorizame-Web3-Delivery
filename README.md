# 🚀 AutorizaMe-Web3-Delivery

**Sistema de Autorización con Blockchain e IPFS para mensajería y reparto.**

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-6DB33F?style=for-the-badge&logo=spring-boot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![Ethereum](https://img.shields.io/badge/Ethereum-3C3C3D?style=for-the-badge&logo=ethereum&logoColor=white)](https://ethereum.org/)
[![IPFS](https://img.shields.io/badge/IPFS-65C2CB?style=for-the-badge&logo=ipfs&logoColor=white)](https://ipfs.tech/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)

AutorizaMe-Web3-Delivery es una solución integral para la gestión de autorizaciones en el reparto de pedidos utilizando tecnologías de **Blockchain** y almacenamiento descentralizado (**IPFS**). El sistema garantiza la seguridad y trazabilidad mediante el uso de **NFTs** que actúan como credenciales digitales.

## 📐 Arquitectura del Sistema

```mermaid
graph TD
    User((Usuario/Postman)) -- API REST --> Spring[Backend Spring Boot]
    
    subgraph "Capa de Microservicios Node.js"
        Spring -- RestClient --> MS_IPFS[ms_wrapper_ipfs]
        Spring -- RestClient --> MS_SC[ms_wrapper_sc]
    end

    subgraph "Infraestructura Externa"
        Spring -- JPA/Hibernate --> DB[(PostgreSQL Supabase)]
        MS_IPFS -- SDK --> Pinata[IPFS / Pinata]
        MS_SC -- Ethers.js --> Blockchain[Blockchain Sepolia]
    end

    %% Colores mejorados para visibilidad
    style Spring fill:#6DB33F,stroke:#333,stroke-width:2px,color:#fff
    style MS_IPFS fill:#339933,stroke:#333,stroke-width:1px,color:#fff
    style MS_SC fill:#339933,stroke:#333,stroke-width:1px,color:#fff
    style DB fill:#336791,stroke:#333,stroke-width:1px,color:#fff
    style Pinata fill:#65C2CB,stroke:#333,stroke-width:1px,color:#fff
    style Blockchain fill:#3C3C3D,stroke:#333,stroke-width:1px,color:#fff
```

---

## 🏗️ Estructura del Proyecto

- **`🍃 Autorizame-api/`**: Backend principal en Spring Boot. Orquestador de lógica, validaciones y persistencia JPA.
- **`📦 ms_wrapper_ipfs/`**: Microservicio Node.js para interactuar con el SDK de Pinata/IPFS.
- **`⛓️ ms_wrapper_sc/`**: Microservicio Node.js para el minteo y transferencia de Smart Contracts (Ethers.js).
- **`📜 contracts/`**: Directorio con el código fuente del Smart Contract (`Autorizame.sol`).
- **`🚜 Farmville/`**: Módulo adicional de procesamiento de datos JDBC y gestión de archivos.

---

## 📡 Catálogo de Endpoints

### 🍃 Backend Spring Boot (API Principal)
| Método | Endpoint | Acción |
| :--- | :--- | :--- |
| `POST` | `/api/v1/pedidos` | **✨ Auto:** Crea registro -> Sube Metadata a IPFS -> Minta NFT en Blockchain. |
| `GET` | `/api/v1/pedidos` | 📋 Consulta todos los pedidos y sus detalles Web3. |
| `GET` | `/api/v1/pedidos/{id}` | 🔍 Detalle de un pedido y sus estados de blockchain. |
| `GET` | `/api/v1/pedidos/blockchain/metadata/{cid}` | ☁️ Recupera el JSON original desde IPFS a través de Spring. |
| `POST` | `/api/v1/pedidos/{id}/transferir` | 🤝 Transfiere la propiedad del NFT al autorizado (Cierre de pedido). |

### 📦 Wrapper IPFS (8081) / ⛓️ Smart Contract (8082)
Endpoints internos invocados de forma transparente por el Backend gestionados mediante `RestClient` de Spring Boot.

---

## 🛠️ Configuración Rápida

1. **🔑 Base de Datos:** Configurar credenciales en `Autorizame-api/src/main/resources/application.properties`.
2. **🔑 IPFS/SC:** Configurar archivos `.env` con las API Keys de Pinata y la Private Key de la Wallet.
3. **🚀 Ejecución simultánea:**
   ```bash
   # Iniciar Microservicios
   npm start --prefix ms_wrapper_ipfs
   npm start --prefix ms_wrapper_sc
   
   # Iniciar Spring Backend
   cd Autorizame-api && ./mvnw spring-boot:run
   ```

---

## 👥 Autor
- **Iván Ramírez** - [@ivanramirez2](https://github.com/ivanramirez2)
