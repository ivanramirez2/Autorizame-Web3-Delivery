// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.30;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title AutoriZame NFT - Autorización de pedidos mediante ERC-721
/// @author Iván Ramírez
/// @notice Representa autorizaciones que pasan Cliente → Autorizado → Repartidor.

contract AutorizameNFT is ERC721URIStorage, Ownable {


    // =========================================================
    //                     ESTRUCTURA DEL PEDIDO
    // =========================================================

    struct Pedido {
        uint256 idPedido;
        address cliente;
        address autorizado;
        string metadataURI; 
    }

    // =========================================================
    //                     VARIABLES DE ESTADO
    // =========================================================

    uint256 public currentTokenId;

    /// @notice Address del repartidor autorizado a quemar tokens
    address public repartidor;

    /// @dev tokenId → Pedido
    mapping(uint256 => Pedido) private _pedidos;

    /// @dev Listado de tokens por cliente
    mapping(address => uint256[]) private _tokensPorCliente;

    /// @dev Listado de tokens por autorizado
    mapping(address => uint256[]) private _tokensPorAutorizado;



    // =========================================================
    //                           EVENTOS
    // =========================================================

    event PedidoMint(
        uint256 indexed idPedido,
        uint256 indexed idToken,
        address indexed cliente
    );

    event AutorizacionTransferida(
        uint256 indexed idPedido,
        uint256 indexed idToken,
        address indexed nuevoOwner
    );

    event AutorizacionQuemada(
        uint256 indexed idToken,
        address indexed quemadoPor
    );



    // =========================================================
    //                            ERRORES
    // =========================================================

    error NoEsPropietario(address caller, uint256 tokenId);
    error SoloRepartidor(address caller, address repartidorEsperado);



    // =========================================================
    //                        MODIFICADORES
    // =========================================================

    modifier onlyRepartidor() {
        if (msg.sender != repartidor) {
            revert SoloRepartidor(msg.sender, repartidor);
        }
        _;
    }



    // =========================================================
    //                        CONSTRUCTOR
    // =========================================================

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) Ownable(msg.sender) {}



    // =========================================================
    //                     CONFIGURACIÓN
    // =========================================================

    function setRepartidor(address _repartidor) external onlyOwner {
        require(_repartidor != address(0), "Repartidor no puede ser cero");
        repartidor = _repartidor;
    }



    // =========================================================
    //                           MINT
    // =========================================================

    /// @notice Mint de un NFT cuando se registra un pedido
    /// @dev Lo hace el backend (owner). Se asigna directamente al cliente.
    function mintPedido(
        uint256 idPedido_,
        address cliente_,
        address autorizado_,
        string memory metadataURI_
    ) external onlyOwner {

        require(cliente_ != address(0), "Cliente no puede ser cero");
        require(autorizado_ != address(0), "Autorizado no puede ser cero");

        uint256 newId = currentTokenId;

        _safeMint(cliente_, newId);
        _setTokenURI(newId, metadataURI_);

        _pedidos[newId] = Pedido({
            idPedido: idPedido_,
            cliente: cliente_,
            autorizado: autorizado_,
            metadataURI: metadataURI_
        });

        _tokensPorCliente[cliente_].push(newId);
        _tokensPorAutorizado[autorizado_].push(newId);

        currentTokenId++;

        emit PedidoMint(idPedido_, newId, cliente_);
    }



    // =========================================================
    //             TRANSFERENCIA DE AUTORIZACIÓN
    // =========================================================

    /// @notice Cliente → Autorizado / Autorizado → Repartidor
    /// @dev Debe ser owner del token o se lanza ErrorPersonalizado
    function transferirAutorizacion(address nuevoOwner, uint256 tokenId) external {

        if (msg.sender != ownerOf(tokenId)) {
            revert NoEsPropietario(msg.sender, tokenId);
        }

        require(nuevoOwner != address(0), "Nuevo owner no puede ser cero");

        _transfer(msg.sender, nuevoOwner, tokenId);

        emit AutorizacionTransferida(
            _pedidos[tokenId].idPedido,
            tokenId,
            nuevoOwner
        );
    }



    // =========================================================
    //                          BURN
    // =========================================================

    /// @notice El repartidor quema el token cuando entrega el pedido
    /// @dev Solo si el repartidor es el owner
    function quemarAutorizacion(uint256 tokenId) external onlyRepartidor {

        if (msg.sender != ownerOf(tokenId)) {
            revert NoEsPropietario(msg.sender, tokenId);
        }

        _burn(tokenId);

        emit AutorizacionQuemada(tokenId, msg.sender);
    }



    // =========================================================
    //               FUNCIONES DE CONSULTA (VIEW)
    // =========================================================


    function propietarioDe(uint256 tokenId) external view returns (address) {
        return ownerOf(tokenId);
    }

    function obtenerTokensPorCliente(address cliente) external view returns (uint256[] memory){
        return _tokensPorCliente[cliente];
    }

    function obtenerTokensPorAutorizado(address autorizado) external view returns (uint256[] memory){
        return _tokensPorAutorizado[autorizado];
    }
 
    function obtenerPedidosPorCliente(address cliente)external view returns (Pedido[] memory pedidosCliente){
        uint256[] memory tokens = _tokensPorCliente[cliente];
        pedidosCliente = new Pedido[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            pedidosCliente[i] = _pedidos[tokens[i]];
        }
    }

    function obtenerPedidosPorAutorizado(address autorizado)external view returns (Pedido[] memory pedidosAutorizado){
        uint256[] memory tokens = _tokensPorAutorizado[autorizado];
        pedidosAutorizado = new Pedido[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            pedidosAutorizado[i] = _pedidos[tokens[i]];
        }
    }
}
