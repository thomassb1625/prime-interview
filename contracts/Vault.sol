pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PUSD.sol";

contract Vault is Ownable {
    address public primeAddress;
    address public PUSDAddress;
     
    mapping (address => uint256) userPrincipal;
    mapping (address => uint256) lockTime;
    mapping (address => uint256) unclaimedRewards;
    
    function depositPrime(uint256 amount) public  {
        require(IERC20(primeAddress).balanceOf(msg.sender) >= amount, "Your token amount must be greater then you are trying to deposit");
        require(IERC20(primeAddress).transferFrom(msg.sender, address(this), amount));

        unclaimedRewards[msg.sender] += getRewards(msg.sender);
        userPrincipal[msg.sender] += amount;
        lockTime[msg.sender] = block.timestamp;

    }

    function withdrawalPrincipal(uint256 _amount) public {
        require(userPrincipal[msg.sender] >= _amount);
        require(IERC20(primeAddress).approve(address(this), _amount), "Approve failed");
        require(IERC20(primeAddress).transferFrom(address(this), msg.sender, _amount), "Transfer failed");
        unclaimedRewards[msg.sender] += getRewards(msg.sender);
        lockTime[msg.sender] = block.timestamp;
    }

    function claimRewards(uint256 _amount) public {
        uint256 totalRewards = getRewards(msg.sender) + unclaimedRewards[msg.sender];
        require(totalRewards >= _amount, "Not enough rewards to withdrawal");
       
        PUSD(PUSDAddress).mint(_amount, msg.sender);

        unclaimedRewards[msg.sender] = totalRewards - _amount;
        lockTime[msg.sender] = block.timestamp;
    }

    function getRewards(address _addr) public view returns(uint256) {
        uint256 timeSinceLock = block.timestamp - lockTime[_addr];
        uint256 rewards = (userPrincipal[_addr]*timeSinceLock)/(365*24*60*60*100);
        return rewards;
    }

    function getPrincipal(address _addr) external view returns(uint256) {
        return userPrincipal[_addr];
    }

    function setPUSD(address _PUSD) external onlyOwner {
        PUSDAddress = _PUSD;
    }

    function setPrime(address _primeAddr) external onlyOwner {
        primeAddress = _primeAddr;
    }

}