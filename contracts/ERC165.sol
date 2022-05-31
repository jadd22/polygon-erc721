//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interface/IERC165.sol";

contract ERC165 is IERC165 {
    /// @notice Storing Interface ID of IERC165
    /// @dev Get keccak256 of interface functions and convert it to bytes4
    /// keccak256('supportsInterface(bytes4)') == "0x01ffc9a7a5cef8baa21ed3c5c0d7e23accb804b619e9333b597f47a0d84076e2"
    /// bytes4(keccak256('supportsInterface(bytes4)')) == '0x01ffc9a7'

    bytes4 private constant ERC165_INTERFACE_ID = 0x01ffc9a7;

    /// @notice Look up table of all supported interfaces
    /// @dev store interface id with their status

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor() {
        _registerInterface(ERC165_INTERFACE_ID);
    }

    /**
     * @dev See {IERC15-supportsInterface}.
     */
    function supportsInterface(bytes4 _interfaceId)
        external
        override
        view
        returns (bool status)
    {
        return _supportedInterfaces[_interfaceId];
    }

    /// @notice Revert if interface is '0xffffffff'
    /// @dev Set status of contract interface id into allowed mapping.
    /// @param _interfaceId takes contract interface id.
    /// @return status Returns status of contract execution

    function _registerInterface(bytes4 _interfaceId)
        internal
        returns (bool status)
    {
        require(
            _interfaceId != 0xffffffff,
            "ERC165: InterfaceId not supported"
        );
        _supportedInterfaces[_interfaceId] = true;
        return true;
    }
}
