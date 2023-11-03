// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWokenFactory {
    function isTradingOpen(address token) external view returns (bool);
}

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/merge/release-v4.9/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/merge/release-v4.9/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/merge/release-v4.9/contracts/access/Ownable.sol";

contract Woken is ERC20, ERC20Permit, Ownable {
    address public wokenFactory;
    address public pairAddress;
    bool public timekeeperEnabled = false;

    event TimekeeperEnabled(bool enabled);

    modifier tradingMustBeOpen() {
        if (timekeeperEnabled) {
            require(
                IWokenFactory(wokenFactory).isTradingOpen(pairAddress),
                "WokenExchange : Trading / Transfer is Closed"
            );
        }
        _;
    }

    constructor() ERC20("Woken", "WKN") ERC20Permit("Woken") {
        _mint(msg.sender, 300000000 * 10**18);
    }

    function setWokenFactory(address _wokenFactory) external onlyOwner {
        wokenFactory = _wokenFactory;
    }

    function setPairAddress(address _pairAddress) external onlyOwner {
        pairAddress = _pairAddress;
    }

    function enableTimekeeper(bool _enabled) external onlyOwner {
        require(
            wokenFactory != address(0) && pairAddress != address(0),
            "Missing wokenFactory or pairAddress"
        );
        require(
            timekeeperEnabled != _enabled,
            _enabled
                ? "Timekeeper already enabled."
                : "Timekeeper already disabled."
        );
        timekeeperEnabled = _enabled;
        emit TimekeeperEnabled(_enabled);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override tradingMustBeOpen {
        super._beforeTokenTransfer(from, to, amount);
    }
}