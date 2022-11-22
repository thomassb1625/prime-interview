pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";



contract PUSD is ERC20 {
    address vaultAddr;
    
    constructor(string memory name, string memory symbol, address vault)
        public
        ERC20(name, symbol)
    {
        vaultAddr = vault;
    }

    function mint(uint256 _amount, address _user) public {
        require(msg.sender == vaultAddr);
        _mint(_user, _amount);
    }
}