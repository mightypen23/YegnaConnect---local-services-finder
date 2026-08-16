
# YegnaConnect

A mobile-first app connecting households with skillful local service proffessionals. 


## Features

- Location based connection with the nearest provider
- Offline queue system
- Cross-platform
- Category filtering
- Service provider rating / community trust score

## Authors

- [Yitayal Yalelet (CTC-668-26)](https://www.github.com/mightypen23)
- [Kebron Ashenafi (CTC-673-26)](https://www.github.com/Kebron-developer)
- [Dawit Birhanu(CTC-4732-26)](https://www.github.com/Dawit2060)
- [Yishak Abel (CTC-1212-26)](https://www.github.com/yishakabel76-svg )
- [Zinegnaw  (CTC-514-26)](https://www.github.com/Zinawk)




## Tech Stack

![](https://skillicons.dev/icons?i=flutter,nodejs,postgres,)



## Documentation

[Documentation](https://linktodocumentation)


## Installation

Install my-project with npm

```bash
  npm install my-project
  cd my-project
```
    
## Application Structure

📱 Application Structure

The Flutter application follows a feature-oriented Clean Architecture.

lib/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   ├── controllers/
│   ├── navigation/
│   └── localization/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
├── data/
│   ├── api/
│   ├── database/
│   ├── models/
│   ├── repositories/
│   └── synchronization/
│
└── core/
    ├── network/
    ├── permissions/
    ├── errors/
    ├── constants/
    ├── logging/
    └── dependency_injection/