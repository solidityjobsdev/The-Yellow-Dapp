pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);
    
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
  
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
  
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract CBK is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address private _owner;
    bool public mintingFinished = false;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner is allowed to access this function.");
        _;
    }

    constructor () public {
        _name = "CBK";
        _symbol = "CBK";
        _decimals = 18;
        _owner = msg.sender;
        _totalSupply = 100000000 ether;
        _balances[msg.sender] = _totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    
    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }

    function mint(address account, uint256 amount) onlyOwner public {
        require(account != address(0), "ERC20: mint to the zero address");
        require(!mintingFinished);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function finishMinting() onlyOwner public {
        mintingFinished = true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        _owner = newOwner;
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity ^0.6.0;

contract PrivateSale {
    
    using SafeMath for uint256;
    
    address payable public owner;
    uint256 public ratio = 9000000000000;
    IERC20 public token;
    IERC20 public usdc;
    IUniswapV2Pair public uni;
    uint256 public tokensSold;
    bool public saleEnded;
    uint256 public minimum = 45000 ether;
    uint256 public limit = 180000 ether;
    
    mapping(address => uint256) public permitted;
    
    event TokensPurchased(address indexed buyer, uint256 tokens, uint256 usdc, uint256 eth);
    event SaleEnded(uint256 indexed unsoldTokens, uint256 indexed collectedUSDC, uint256 indexed collectedETH);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner is allowed to access this function.");
        _;
    }
    
    constructor (address tokenAddress, address usdcAddress, address uniAddress) public {
        
        token = IERC20(tokenAddress);
        usdc = IERC20(usdcAddress);
        uni = IUniswapV2Pair(uniAddress);
        owner = msg.sender;
    }


    function permit(address account) onlyOwner public {
        permitted[account] += limit;
    }
    
    function setLimits(uint256 min, uint256 max) onlyOwner public {
        minimum = min;
        limit = max;
    }
    
    receive() external payable {
        buyWithETH();
    }
    
    function buyWithUSDC(uint256 amountUSDC) public {

        uint256 tokens = amountUSDC.mul(ratio);
        require(!saleEnded, "Sale has already ended");
        require(tokens <= token.balanceOf(address(this)), "Not enough tokens for sale");
        require(tokens <= permitted[msg.sender], "The amount exceeds your limit");
        require(tokens >= minimum, "The amount is less than minimum");
        permitted[msg.sender] -= tokens;
        require(usdc.transferFrom(msg.sender, address(this), amountUSDC));        
        require(token.transfer(msg.sender, tokens));
        tokensSold += tokens;

        emit TokensPurchased(msg.sender, tokens, amountUSDC, 0);
    }

    function buyWithETH() payable public {

        (uint112 a, uint112 b, uint32 c) = uni.getReserves();
        uint256 tokens = msg.value.mul(ratio).mul(a).div(b);
        require(!saleEnded, "Sale has already ended");
        require(tokens <= token.balanceOf(address(this)), "Not enough tokens for sale");
        require(tokens <= permitted[msg.sender], "The amount exceeds your limit");
        require(tokens >= minimum, "The amount is less than minimum");
        permitted[msg.sender] -= tokens;
        token.transfer(msg.sender, tokens);
        tokensSold += tokens;

        emit TokensPurchased(msg.sender, tokens, 0, msg.value);
    }
    
    function endSale() onlyOwner public {
        uint256 tokens = token.balanceOf(address(this));
        uint256 usd = usdc.balanceOf(address(this));
        uint256 eth = address(this).balance;
        token.transfer(owner, tokens);
        usdc.transfer(owner, usd);
        owner.transfer(eth);
        saleEnded = true;
        emit SaleEnded(tokens, usd, eth);
    }
    
    
}