# Citrix-CVAD-VDI-UUID-Changer
Citrix VDI 관련 UUID 변경 툴

## 실행화면
![image](https://user-images.githubusercontent.com/126259075/233948774-ee8e7256-c71f-40f0-85fa-e059bc255e38.png)

----------

# 개요

* 해당 툴의 목적은 기존 운영중인 기존(예시:Xenserver)가상화 시스템에서 다른(예시:VMware ESXi)전환 될 Hypervisor 풀에서
  신규로 Master 이미지를 만든 후 카탈로그를 추가 생성하여 진행해야 되지만 해당 툴은 기존 카탈로그에서도 풀간 전환이 가능하도록 만들었습니다.
* Exising 카탈로그에서는 파워쉘 등으로 UUID 및 컨넥션 변경이 일부 가능하지만 MCS 방식인 Dedicated,Pooled VM에서는 변경이 불가능하게 되어있습니다.
* 이를 가능하기 위해 SQL 쿼리를 이용하여 UUID 및 Hypervisor 컨넥션등을 강제로 교체할 수 있습니다.
* 해당 툴에서는 MSSQL 쿼리를 적용하는 방식인 SQLCMD 커맨드가 적용 되어있습니다.
* 해당 툴은 7.6 ~ 7 2203 버전까지 테스트 완료하여 정상적으로 작동 되는 것을 확인했습니다.

(모든 7버전에서 될 것으로 예상되나 7.6 이상에서 사용하는 것을 권장드립니다.)

(그 이하 버전인 6버전 및 5버전은 테이블 방식이 다름으로 권장하지 않습니다.)
## 주의사항
## !! 진행하기전에 CVAD DB를 백업 후 진행하는 것을 권장드립니다.  
----------

# 0. 초기 구성
## 1) MVC_X._Ver.bat 실행
* 압축 풀기 후 bin디렉토리내에 내용과 같이 압축 풀기 진행 
* bat경로내에 bin디렉토리가 존재하지 않을 시 작동 불가, bin내 파일이 없을 시 작동불가

* 과정: MVC_x._ver.bat 실행 --> SQL 서버 인증 방식 선택(예시는 4. 분할 구성 (SQL Server 인증)) --> DB서버 접속 정보 입력(단 미러 서버로 구성 시 주서버만 입력)

  --> Site,Monitoring DB명/DB_User,Password 입력 --> ODBC,SQLCMD 미설치 시 자동설치 진행(자동으로 관리자권한으로 설치)
  --> 설치 완료 후 메인화면 및 config.conf파일 생성 확인

  DB패스워드(sapass)부분은 보안상 암호화로 저장

<img width="448" alt="image" src="https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/90279711-4844-46ee-a946-5428bd894e8a">
<img width="876" alt="image" src="https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/a7411919-3541-4a7c-9608-d137edf97062">
<img width="460" alt="image" src="https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/258239cc-e9df-4a8b-b1a3-bf4ecd49a455">
<img width="1312" alt="image" src="https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/d236ebb4-240b-47f1-9142-652ad91e675e">
<img width="528" alt="image" src="https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/434d4c9c-c75c-4196-9414-02253cbe2647">
<img width="945" alt="image" src="https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/e975095a-50d0-41df-8ec7-3f879a59adea">



# 1. 단일모드 구성
## 1) VM_UUID 변경
과정:대상 지정 --> 현재 등록된 VM UUID 확인 --> MVC.bat 메인메뉴 1번 입력 --> 대상VM의 현재 UUID 입력(Xenserver) --> 바꿀 UUID값 입력(VMware ESXi) --> 적용
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/16f5971b-5fc1-4f9d-8d79-80bf97854741)
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/25caa8a7-25c0-420b-868e-19f470ac85da)
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/1b95821a-8ab9-4957-b4e9-c39ed3ba5691)

## 2) VM_POOL 컨넥션 변경
- VM UUID 변경 후 Xenserver 에서 vCenter 으로 변경
과정: MVC.bat 메인메뉴 2번 입력 --> 현재 등록된 VM UUID 입력 --> DDC에 등록된 하이퍼바이저 목록에서 변경할 하이퍼바이저 Uid 번호 지정 --> 적용
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/41dc98e3-11cb-4929-b921-a19413fe898c)
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/d7ac58e5-73cf-463f-b4f8-276033383a93)

## 3) 최종 결과
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/ae596f3d-5097-488b-abb1-4cc9d3db52d0)
변경 후 Citrix Studio에서 해당 VM의 PowerState가 Uknown으로 나올 시 모든 DDC컨트롤러 서버의 Citrix Broker Service 재기동 진행

# 2.다량의 VM변경 모드(CSV파일 이용)
## 1) 모든 브로커 머신의 리스트 CSV파일 내보내기 진행
과정: MVC.bat 메인메뉴 6번 입력 --> 다량의 데이터 처리하기 메뉴에서 1번 입력 --> 저장된 MVCCSV.csv파일 엑셀로 확인
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/11c92fcf-529f-4032-8931-cef332deaf41)
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/820492a1-cd68-40b2-bc1e-278aa8036dd0)
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/ab724ca1-8fc4-449f-8b2b-69723c93d9bb)

## 2) CSV양식에서 값 변경 후 불러오기 진행
- 과정1: 기존의 MVCCSV.csv 파일 변경 진행 
- 주의: 해당 csv양식에서 VMUid,HypervisorName 2개의 컬럼 내용만 변경이 가능합니다.
    - 추가로 VMName 컬럼은 해당 하이퍼바이저의 VM명과 일치하도록 진행합니다. 
    - 예시)
    -      leedkTEST01 --> Copy_leedkTEST01 X
    -      leedkTEST01 --> leedkTEST01 O
- 캡쳐 내용참고
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/bb880c67-5bac-413c-879e-1c9f2d257708)
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/e8740fda-7ff6-49ae-965c-1d7dfbc489b7)
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/4b599e22-1e9f-48e3-ba15-2064d62fd8ea)


과정2: MVC.bat 메인메뉴 6번 입력 --> 다량의 데이터 처리하기 메뉴에서 2번 입력 --> 불러올 CSV파일 드래그앤 드랍 및 파일경로 입력하기
- 참고: 파일경로 입력이 띄어쓰기가 있으면 경로에 "C:\Users\user\Desktop\MVCCSV.csv" 첫글자와 끝글자에 쌍따옴표" 을 붙여서 진행
- 공란으로 비운 상태로 엔터만 입력 시 기본경로인 "CSV\MVCCSV.csv" 으로 자동 지정, 이건 해당 파일이 있을시만 해당
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/d2826dcf-cc59-4080-a3bd-e4207bfeaeeb)

## 3) 최종 결과
- Citrix Studio상 컨넥션만 확인이 가능 
- 부팅 시 XenServer가 아닌 VMware ESXi 서버로 부팅 되는 것을 확인 , MCS VM의 하이퍼바이저 풀간 마이그레이션 성공
- 변경 후 Citrix Studio에서 해당 VM의 PowerState가 Uknown으로 나올 시 모든 DDC컨트롤러 서버의 Citrix Broker Service 재기동 진행
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/a6cb5e0b-299a-4271-872a-9ecd8d674157)
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/ce8b7ef6-47d2-4f05-9789-3aee108a8d39)


