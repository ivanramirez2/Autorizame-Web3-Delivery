import 'dotenv/config';
import express from 'express';
import pinataSDK from '@pinata/sdk';

const app = express();
app.use(express.json());

const { PORT = 8081, PINATA_JWT, PINATA_GATEWAY } = process.env;
if (!PINATA_JWT || !PINATA_GATEWAY) throw new Error("Faltan PINATA_JWT o PINATA_GATEWAY");

const pinata = new pinataSDK({ pinataJWTKey: PINATA_JWT });

app.post('/subirMetadata', async (req, res) => {
  try {
    const body = req.body;
    const required = ["idPedido", "addressCliente", "addressAutorizado", "timestamp"];
    for (const f of required) if (!body[f]) return res.status(400).json({ error: `Falta ${f}` });

    console.log("[IPFS] Subiendo metadata:", body);

    const result = await pinata.pinJSONToIPFS(body, {
      pinataMetadata: { name: `pedido-${body.idPedido}` }
    });

    const cid = result.IpfsHash;
    const url = `https://${PINATA_GATEWAY}/ipfs/${cid}`;

    console.log("[IPFS] OK CID:", cid);
    res.json({ cid, url });

  } catch (e) {
    console.error("[IPFS] Error:", e);
    res.status(500).json({ error: e.message });
  }
});

app.get('/recuperarMetadata/:cid', async (req, res) => {
  try {
    const { cid } = req.params;
    const url = `https://${PINATA_GATEWAY}/ipfs/${cid}`;

    console.log("[IPFS] Recuperando:", url);

    const r = await fetch(url);
    if (!r.ok) return res.status(404).json({ error: "No encontrado" });

    res.json(await r.json());

  } catch (e) {
    console.error("[IPFS] Error:", e);
    res.status(500).json({ error: e.message });
  }
});

app.listen(PORT, () => console.log(`ms_wrapper_ipfs => http://localhost:${PORT}`));