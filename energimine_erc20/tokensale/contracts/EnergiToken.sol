pragma solidity ^0.4.15;

import "./zeppelin-solidity/contracts/token/MintableToken.sol";
import "./zeppelin-solidity/contracts/math/SafeMath.sol";
import "./zeppelin-solidity/contracts/ownership/Claimable.sol";

contract EnergiToken is MintableToken, Claimable {

  using SafeMath for uint256;

  string public constant name = "EnergiToken";
  string public constant symbol = "ETK";
  string public constant version = "1.0";
  uint8 public constant decimals = 2;

  mapping(address => uint256) frozen;

  function EnergiToken() MintableToken() {
    owner = msg.sender;
  }

 /**
  * @dev transfer token for a specified address method overridden to support freezing accounts
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    require(_to != address(0));
    require(frozen[msg.sender] == 0); // I.e. is not frozen

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(_to != address(0));
    require(frozen[_from] == 0); // I.e. is not frozen

    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
  * @dev Checks if an address is frozen
  * @param _addr The address to query
  * @return An uint256 representing frozen or not. 0 = Unfrozen, 1 = Frozen
  */
  function isFrozen(address _addr) onlyOwner returns (uint256) {
    return frozen[_addr];
  }

  /**
   * @dev Freeze an account - Frozen accounts are not allowed to transfer
   * @param _addr address The address to freeze
   */
  function freezeAddress (address _addr) onlyOwner returns (bool) {
    require(_addr != address(0));
    frozen[_addr] = 1;
    return true;
  }

  /**
   * @dev Thaw an account - Un-freeze a previously frozen account
   * @param _addr address The address to thaw
   */
  function thawAddress (address _addr) onlyOwner returns (bool) {
    require(_addr != address(0));
    frozen[_addr] = 0;
    return true;
  }

}
