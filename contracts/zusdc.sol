// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {
    ERC20Permit
} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Zusdc is ERC20, Ownable, ERC20Permit {
    constructor(
        address initialOwner
    ) ERC20("Zusdc", "ZUSDC") Ownable(initialOwner) ERC20Permit("Zusdc") {
        //initialOwner에게 초기 토큰 발행(mint)
        // ERC20 내부적으로는 소수점을 제거한 정수 단위로 저장하기 때문에
        // "100만 개 토큰"을 표현하려면 10^6을 곱해줘야 한다.
        _mint(initialOwner, 1000000 * 10 ** decimals());
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
