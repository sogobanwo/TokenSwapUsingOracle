// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../contracts/interface/IERC20.sol";
import {AggregatorV3Interface} from "lib/chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract SwapContract {
    // TSTATE VARIABLES
    IERC20 dai;
    IERC20 link;
    IERC20 weth;

    AggregatorV3Interface eth_usd;
    AggregatorV3Interface link_usd;
    AggregatorV3Interface dai_usd;

    // Events
    event SwapSuccessful(address indexed sender, uint indexed amountA, uint indexed amountB);

    // Constructor to set the ERC-20 tokens being swapped 
    constructor() {

        dai = IERC20(0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357);

        weth = IERC20(0xb16F35c0Ae2912430DAc15764477E179D9B9EbEa);

        link = IERC20(0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5);

        eth_usd = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        link_usd = AggregatorV3Interface(0xc59E3633BAAC79493d908e63626716e204A45EdF);

        dai_usd = AggregatorV3Interface(0x14866185B1962B63C3Ea9E03Bc1da838bab34C19);

    }

 
    function swapEthDai(uint256 _amountA) external {
        require(msg.sender != address(0), "address zero detected");

        require(_amountA > 0 , "Can't exchange zero amount");

        require(weth.balanceOf(msg.sender) >= _amountA, "Insufficient Balance");

        uint _amountB = uint(getDerivedPrice(eth_usd, dai_usd, 18 ));
        

        require(dai.balanceOf(address(this)) >= _amountB, "Not enough tokenB");

        weth.transferFrom(msg.sender, address(this), _amountA);

        dai.transfer(msg.sender , _amountB);

        emit SwapSuccessful(msg.sender, _amountA , _amountB);

    }

      function swapEthLink(uint256 _amountA) external {
        require(msg.sender != address(0), "address zero detected");

        require(_amountA > 0 , "Can't exchange zero amount");

        require(weth.balanceOf(msg.sender) >= _amountA, "Insufficient Balance");

        uint _amountB = uint(getDerivedPrice(eth_usd, link_usd, 18 ));
        
        require(link.balanceOf(address(this)) >= _amountB, "Not enough tokenB");

        weth.transferFrom(msg.sender, address(this), _amountA);

        link.transfer(msg.sender , _amountB);

        emit SwapSuccessful(msg.sender, _amountA , _amountB);

    }

    function swapLinkDai(uint256 _amountA) external {
            require(msg.sender != address(0), "address zero detected");

            require(_amountA > 0 , "Can't exchange zero amount");

            require(link.balanceOf(msg.sender) >= _amountA, "Insufficient Balance");

            uint _amountB = uint(getDerivedPrice(link_usd, dai_usd, 18 ));
            

            require(dai.balanceOf(address(this)) >= _amountB, "Not enough tokenB");

            link.transferFrom(msg.sender, address(this), _amountA);

            dai.transfer(msg.sender , _amountB);

        emit SwapSuccessful(msg.sender, _amountA , _amountB);


    }

    function swapLinkEth(uint256 _amountA) external {
        require(msg.sender != address(0), "address zero detected");

        require(_amountA > 0 , "Can't exchange zero amount");

        require(link.balanceOf(msg.sender) >= _amountA, "Insufficient Balance");

        uint _amountB = uint(getDerivedPrice(link_usd, eth_usd, 18 ));
        

        require(weth.balanceOf(address(this)) >= _amountB, "Not enough tokenB");

        link.transferFrom(msg.sender, address(this), _amountA);

        weth.transfer(msg.sender , _amountB);

        emit SwapSuccessful(msg.sender, _amountA , _amountB);

    }
  

 function swapDaiLink(uint256 _amountA) external {
        require(msg.sender != address(0), "address zero detected");

        require(_amountA > 0 , "Can't exchange zero amount");

        require(dai.balanceOf(msg.sender) >= _amountA, "Insufficient Balance");

        uint _amountB = uint(getDerivedPrice(dai_usd, link_usd, 18 ));
        

        require(link.balanceOf(address(this)) >= _amountB, "Not enough tokenB");

        dai.transferFrom(msg.sender, address(this), _amountA);

        link.transfer(msg.sender , _amountB);

        emit SwapSuccessful(msg.sender, _amountA , _amountB);

    }

    function swapDaiEth(uint256 _amountA) external {
        require(msg.sender != address(0), "address zero detected");

        require(_amountA > 0 , "Can't exchange zero amount");

        require(dai.balanceOf(msg.sender) >= _amountA, "Insufficient Balance");

        uint _amountB = uint(getDerivedPrice(dai_usd, eth_usd, 18 ));
        

        require(weth.balanceOf(address(this)) >= _amountB, "Not enough tokenB");

        dai.transferFrom(msg.sender, address(this), _amountA);

        weth.transfer(msg.sender , _amountB);

        emit SwapSuccessful(msg.sender, _amountA , _amountB);


    }
    
      function scalePrice(
        int256 _price,
        uint8 _priceDecimals,
        uint8 _decimals
    ) internal pure returns (int256) {
        if (_priceDecimals < _decimals) {
            return _price * int256(10 ** uint256(_decimals - _priceDecimals));
        } else if (_priceDecimals > _decimals) {
            return _price / int256(10 ** uint256(_priceDecimals - _decimals));
        }
        return _price;
    }

     function getDerivedPrice(
        AggregatorV3Interface _base,
        AggregatorV3Interface _quote,
        uint8 _decimals
    ) public view returns (int256) {
        require(
            _decimals > uint8(0) && _decimals <= uint8(18),
            "Invalid _decimals"
        );
        int256 decimals = int256(10 ** uint256(_decimals));
        (, int256 basePrice, , , ) = _base.latestRoundData();
        uint8 baseDecimals = _base.decimals();
        basePrice = scalePrice(basePrice, baseDecimals, _decimals);

        (, int256 quotePrice, , , ) = _quote.latestRoundData();
        uint8 quoteDecimals = _quote.decimals();
        quotePrice = scalePrice(quotePrice, quoteDecimals, _decimals);

        return (basePrice * decimals) / quotePrice;
    }

}


 