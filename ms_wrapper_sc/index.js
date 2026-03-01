import 'dotenv/config';
import express from 'express';
import { ethers } from 'ethers';

const app = express();
app.use(express.json());

const {
  PORT = 8082,
  RPC_URL,
  CONTRACT_ADDRESS,
  OWNER_PRIVATE_KEY
} = process.env;

// Validación inicial
if (!RPC_URL || !CONTRACT_ADDRESS || !OWNER_PRIVATE_KEY) {
  throw new Error("Faltan variables en .env");
}

console.log("Conectando a Sepolia...");
const provider = new ethers.JsonRpcProvider(RPC_URL);

// ABI mínima necesaria del contrato
const ABI = [
  "function mintPedido(uint256 idPedido_, address cliente_, address autorizado_, string metadataURI_) external",
  "function transferirAutorizacion(address nuevoOwner, uint256 tokenId) external",
  "function currentTokenId() view returns (uint256)",
  "function owner() view returns (address)"
];

// Wallet owner (backend)
const ownerWallet = new ethers.Wallet(OWNER_PRIVATE_KEY, provider);
const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, ownerWallet);

// Comprobar owner al arrancar
(async () => {
  try {
    const ownerOnChain = await contract.owner();
    console.log("Owner contrato:", ownerOnChain);
    console.log("Wallet backend:", ownerWallet.address);
  } catch (e) {
    console.error("Error conectando al contrato:", e.message);
  }
})();

// =======================================
// POST mintarAutorizacion
// =======================================
app.post('/mintarAutorizacion', async (req, res) => {
  try {
    const { idPedido, cliente, autorizado, tokenURI } = req.body;

    if (!idPedido || !cliente || !autorizado || !tokenURI) {
      return res.status(400).json({
        error: "Campos requeridos: idPedido, cliente, autorizado, tokenURI"
      });
    }

    console.log("Mint request:", req.body);

    // Obtener tokenId antes de mintear
    const nextTokenId = await contract.currentTokenId();

    const tx = await contract.mintPedido(
      idPedido,
      cliente,
      autorizado,
      tokenURI
    );

    console.log("Tx enviada:", tx.hash);

    const receipt = await tx.wait();

    console.log("Tx confirmada en bloque:", receipt.blockNumber);

    res.json({
      txHash: tx.hash,
      tokenId: nextTokenId.toString()
    });

  } catch (err) {
    console.error("Error mint:", err);
    res.status(500).json({ error: err.message });
  }
});

// =======================================
// POST transferirAutorizacion
// =======================================
app.post('/transferirAutorizacion', async (req, res) => {
  try {
    const { clientePrivateKey, nuevoOwner, tokenId } = req.body;

    if (!clientePrivateKey || !nuevoOwner || tokenId === undefined) {
      return res.status(400).json({
        error: "Campos requeridos: clientePrivateKey, nuevoOwner, tokenId"
      });
    }

    const clienteWallet = new ethers.Wallet(clientePrivateKey, provider);
    const contractCliente = new ethers.Contract(
      CONTRACT_ADDRESS,
      ABI,
      clienteWallet
    );

    console.log("Transfer request:", {
      from: clienteWallet.address,
      to: nuevoOwner,
      tokenId
    });

    const tx = await contractCliente.transferirAutorizacion(
      nuevoOwner,
      tokenId
    );

    console.log("Tx enviada:", tx.hash);

    await tx.wait();

    res.json({
      txHash: tx.hash,
      tokenId: tokenId.toString(),
      nuevoOwner
    });

  } catch (err) {
    console.error("Error transfer:", err);
    res.status(500).json({ error: err.message });
  }
});

// =======================================

app.listen(PORT, () => {
  console.log(`ms_wrapper_sc => http://localhost:${PORT}`);
});