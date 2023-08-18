# Citrix-CVAD-VDI-UUID-Changer
Citrix VDI 관련 UUID 변경 툴

## 실행화면
![image](https://user-images.githubusercontent.com/126259075/233948774-ee8e7256-c71f-40f0-85fa-e059bc255e38.png)

## 주의사항
진행하기전에 CVAD DB백업 후 진행하는 것을 권장드립니다.  

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
    - 예시) leedkTEST01 --> Copy_leedkTEST01 X
           / leedkTEST01 --> leedkTEST01 O
- 캡쳐 내용참고
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/bb880c67-5bac-413c-879e-1c9f2d257708)
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/e8740fda-7ff6-49ae-965c-1d7dfbc489b7)
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/4b599e22-1e9f-48e3-ba15-2064d62fd8ea)


과정2: MVC.bat 메인메뉴 6번 입력 --> 다량의 데이터 처리하기 메뉴에서 2번 입력 --> 불러올 CSV파일 드래그앤 드랍 및 파일경로 입력하기
- 참고: 파일경로 입력이 띄어쓰기가 있으면 경로에 "C:\Users\user\Desktop\MVCCSV.csv" 첫글자와 끝글자에 쌍따옴표" 을 붙여서 진행
- 공란으로 비운 상태로 엔터만 입력 시 기본경로인 "CSV\MVCCSV.csv" 으로 자동 지정, 이건 해당 파일이 있으시만 해당
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/d2826dcf-cc59-4080-a3bd-e4207bfeaeeb)

## 3) 최종 결과
- Citrix Studio상 컨넥션만 확인이 가능 
- 부팅 시 XenServer가 아닌 VMware ESXi 서버로 부팅 되는 것을 확인 , MCS VM의 하이퍼바이저 풀간 마이그레이션 성공
- 변경 후 Citrix Studio에서 해당 VM의 PowerState가 Uknown으로 나올 시 모든 DDC컨트롤러 서버의 Citrix Broker Service 재기동 진행
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/a6cb5e0b-299a-4271-872a-9ecd8d674157)
![image](https://github.com/LKdiol/Citrix-CVAD-VDI-UUID-Changer/assets/126259075/ce8b7ef6-47d2-4f05-9789-3aee108a8d39)


