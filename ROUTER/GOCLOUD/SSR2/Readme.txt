��л   smalt8  
�������ã�smalt8  

���������Ľ̸̳��������أ�����Ҫ�Ĵ��ֵܣ�����������ð��������ϵ��ɾ����лл
1.        ����������ҳ�棬ϵͳ�������õ��뵼����ѡ�������ã�ѡ���ļ���ѡ������ؽ�ѹ������ssh�ļ������backup-ssh.config���㵼�����ã����ĵȴ������·��������
2.        ������ɺ�ʹ��WinSCP��½·������Ĭ����������192.168.1.1���˿ں�Ϊ22222���û���ʹ��root����������·�������������롣
3.        ��½��ѹ�������S-S R.ipk�ϴ���tmpĿ¼�£����Ž�opkg.conf�ϴ���etcĿ¼�¸���ԭ�����ļ���
4.        ·����������
5.        ����Putty����½192.168.1.1���˿�ͬ��Ϊ22222���û�������ͬ�ϡ���½������opkg update
6.        ˢ����ɺ�����cd /tmp,�س���opkg install S-S R.ipk
7.        ��ɣ���½����·�������Ϳ��Կ�����������������˸�S-S Rѡ�
8.        ���棺����������ݺ��滻/etc/dropbear/authorized_keys�еĹ�ԿΪ���Ĺ�Կ����ɾ��/etc/rc.local�е�echo��/etc/dropbear/authorized_keys �����������˴�Զ�̵�½����·��
9.        WinSCP��Putty��������



opkg install luci-app-shadowsocksR-GFW_1.2.1_ramips_24kec.ipk
opkg install luci-app-koolproxy_3.7.2-3_ramips_24kec.ipk