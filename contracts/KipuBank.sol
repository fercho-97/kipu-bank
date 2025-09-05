// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


contract KipuBank {

    // Errors personalizados

    /// @notice Lanzado cuando el monto de depósito es inválido
    error InvalidDepositAmount();

    /// @notice Lanzado cuando se excede el límite global de depósitos
    error DepositCapReached();

    /// @notice Lanzado cuando el monto de retiro es inválido
    error InvalidWithdrawAmount();

    /// @notice Lanzado cuando el usuario no tiene saldo suficiente
    error InsufficientBalance();

    /// @notice Lanzado cuando el monto de retiro excede el límite permitido por transacción
    error WithdrawLimitExceeded();

    
    // Variables de estado


    /// @notice Límite máximo de retiro por transacción
    uint256 public constant LIMITE_RETIRO = 50 ether;

    /// @notice Límite global de depósitos permitido
    uint256 public immutable bankCap;

    /// @notice Conteo de depósitos realizados
    uint256 public totalDepositos;

    /// @notice Conteo de retiros realizados
    uint256 public totalRetiros;

    /// @notice Balances de cada usuario
    mapping (address => uint256) private balances;


    // Eventos


    /// @notice Emitido cuando un usuario deposita ETH
    event Deposito(address usuario, uint256 monto);

    /// @notice Emitido cuando un usuario retira ETH
    event Retiro(address usuario, uint256 monto);


    // Constructor


    /// @param _bankCap Límite global de depósitos
    constructor(uint256 _bankCap) payable {
        bankCap = _bankCap;
    }



    // Funciones


    /// @notice Deposita ETH en el contrato
    /// @dev Requiere que el monto sea > 0 y no supere el límite global
    function depositar() external payable {
        if (msg.value == 0) revert InvalidDepositAmount();
        if (address(this).balance > bankCap) revert DepositCapReached();

        // Effects
        balances[msg.sender] += msg.value;
        totalDepositos++;

        // Interaction (ninguna externa aquí, seguro)
        emit Deposito(msg.sender, msg.value);
    }

    /// @notice Retira un monto de ETH del balance del usuario
    /// @param montoRetiro Monto a retirar
    function retirar(uint256 montoRetiro) external {
        if (montoRetiro == 0) revert InvalidWithdrawAmount();
        if (montoRetiro > LIMITE_RETIRO) revert WithdrawLimitExceeded();
        if (balances[msg.sender] < montoRetiro) revert InsufficientBalance();

        // Effects
        balances[msg.sender] -= montoRetiro;
        totalRetiros++;

        // Interactions
        _safeTransfer(payable(msg.sender), montoRetiro);

        emit Retiro(msg.sender, montoRetiro);
    }

    /// @notice Devuelve el balance de un usuario
    /// @param usuario Dirección del usuario
    /// @return Balance actual del usuario
    function balanceOf(address usuario) external view returns (uint256) {
        return balances[usuario];
    }



    /// @dev Transferencia segura de ETH, siguiendo buenas prácticas
    /// @param destinatario Dirección que recibirá los fondos
    /// @param monto Cantidad en wei
    function _safeTransfer(address payable destinatario, uint256 monto) private {
        (bool success, ) = destinatario.call{value: monto}("");
        require(success, "Transfer failed");
    }
}
