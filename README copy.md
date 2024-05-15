<!--
*** NB: This template was taken from: https://github.com/othneildrew/Best-README-Template/blob/master/README.md?plain=1 
*** For shields, see: https://shields.io/
-->
<a name="readme-top"></a>

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->


[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/7Cedars/loyalty-program-contracts"> 
    <img src="public/iconLoyaltyProgram.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">Loyal: A Solidity Protocol for Web3 Customer Engagement Programs</h3>

  <p align="center">
    A composable, lightweight and fully open source solidity protocol build for real-world customer engagment. 
    <br />
    <a href="https://github.com/7Cedars/loyalty-program-contracts"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <!--NB: TO DO --> 
    <a href="https://loyalty-program-psi.vercel.app">View Demo of a dApp interacting with the protocol.</a>
    ·
    <a href="https://github.com/7Cedars/loyalty-program-contracts/issues">Report Bug</a>
    ·
    <a href="https://github.com/7Cedars/loyalty-program-contracts/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project
A fully open source solidity protocol for real-world customer engagment.

This protocol sets out a standard for loyalty programs: ERC-1155 based contracts that mint (fungible) points and (non-fungible) loyalty cards.
Loyalty Cards are implemented as ERC-6551 Token Based Accounts that accumulate loyalty points. 
See [this repository](https://github.com/7Cedars/loyalty-program-contracts) for an example implementation. 

Loyalty programs interact with a second protocol that sets out a standard for contracts - loyalty gift contracts - that exchange points for gifts or vouchers.
For this protocol, see [this repository](https://github.com/7Cedars/loyalty-gifts-contracts) for example implementations.

Crucially, interactions between the two protocols are bounded: points and vouchers that are minted by a loyalty program can only be used among its own loyalty cards. 
Loyalty cards themselves are freely transferable.

See the following schema for more detail:

  <a href="https://github.com/7Cedars/loyalty-program-contracts/blob/master/public/PoCModularLoyaltyProgram.png"> 
    <img src="public/PoCModularLoyaltyProgram.png" alt="Schema Protocol" width="100%" height="100%">
  </a>


<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With
<!-- See for a list of badges: https://github.com/Envoy-VC/awesome-badges -->
<!-- * [![React][React.js]][React-url]  -->
* Solidity 0.8.19
* Foundry 0.2.0
* OpenZeppelin 5.0


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running do the following.

### Prerequisites

  Install Foundry
  ```sh
  $ curl -L https://foundry.paradigm.xyz | bash
  ```

  ```sh
  $ foundryup
  ```

  Check if the chain has an ERC-6551 registry at address 0x000000006551c19487814612e58FE06813775758.
  If not (and if the contract is deployed on a local chain), set up a registry following the steps at [tokenbound.org](https://docs.tokenbound.org/guides/deploy-registry). 

### Clone the repository
<!-- NB: I have to actually follow these steps and check if I missed anyting £todo -->

1. Get a free alchemy API Key at [alchemy.com](https://docs.alchemy.com/docs/alchemy-quickstart-guide)
2. Clone the repo
  ```sh
   git clone https://github.com/7Cedars/loyalty-program-contracts.git
   ```
3. Install packages
  ```sh
   yarn add
   ```

### Run the test and build the contracts
4. Run tests
  ```sh
  $ forge test
   ```
5. Build contracts
  ```sh
   $ forge build
   ```

### Deploy
6. Run deploy script at an EVM compatible Chain
  ```sh
   $ forge script --fork-url <RPC_URL> script/DeployLoyaltyProgram.s.sol --broadcast
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- USAGE EXAMPLES -->
## Usage
A front-end dApp demonstration of this web3 protocol has been deployed on vercel.com. 
Try it out at [https://loyalty-program-psi.vercel.app/](https://loyalty-program-psi.vercel.app/). 

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Roadmap

- [ ] Further develop testing. Basic unit, integration and invariant tests have been implemented, but fuzz tests not yet. Test coverage is only around 50 percent.  
- [ ] Implement deployment to multiple testnets. 
- [ ] ... 

See the [open issues](https://github.com/7Cedars/loyalty-program-contracts/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement". Thank you! 

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Seven Cedars - [@7__Cedars](https://twitter.com/7__Cedars) - cedars7@proton.me

GitHub profile [https://github.com/7Cedars](https://github.com/7Cedars)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments
* This project was build while following [PatrickCollins](https://www.youtube.com/watch?v=wUjYK5gwNZs&t) amazing Learn Solidity, Blockchain Development, & Smart Contracts Youtube course. Comes highly recommended for anyone wanting to get into Foundry & intermediate/advanced solidity coding. 
* An [introduction to ERC-6551](https://www.youtube.com/watch?v=GLTVd5P5LCw) by Pinata's Kelly Kim was really useful. 
* As was the documentation from [Tokenbound](https://docs.tokenbound.org/) (an organisation advocating the implementation of Tokan Based Accounts). 
* I took the template for the readme file from [Drew Othneil](https://github.com/othneildrew/Best-README-Template/blob/master/README.md?plain=1). 
* And a special thanks should go out to [SpeedRunEthereum](https://speedrunethereum.com/) and [LearnWeb3](https://learnweb3.io/) for providing the first introductions to solidity coding. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
<!-- [contributors-shield]: https://img.shields.io/github/contributors/7Cedars/loyalty-program-contracts.svg?style=for-the-badge
[contributors-url]: https://github.com/7Cedars/loyalty-program-contracts/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/7Cedars/loyalty-program-contracts.svg?style=for-the-badge
[forks-url]: https://github.com/7Cedars/loyalty-program-contracts/network/members
[stars-shield]: https://img.shields.io/github/stars/7Cedars/loyalty-program-contracts.svg?style=for-the-badge
[stars-url]: https://github.com/7Cedars/loyalty-program-contracts/stargazers -->
[issues-shield]: https://img.shields.io/github/issues/7Cedars/loyalty-program-contracts.svg?style=for-the-badge
[issues-url]: https://github.com/7Cedars/loyalty-program-contracts/issues/
[license-shield]: https://img.shields.io/github/license/7Cedars/loyalty-program-contracts.svg?style=for-the-badge
[license-url]: https://github.com/7Cedars/loyalty-program-contracts/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/linkedin_username
[product-screenshot]: images/screenshot.png
<!-- See list of icons here: https://hendrasob.github.io/badges/ -->
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Tailwind-css]: https://img.shields.io/badge/Tailwind_CSS-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white
[Tailwind-url]: https://tailwindcss.com/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Redux]: https://img.shields.io/badge/Redux-593D88?style=for-the-badge&logo=redux&logoColor=white
[Redux-url]: https://redux.js.org/
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 
