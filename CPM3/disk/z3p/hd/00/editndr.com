�Z3ENV �\���*	��s1�����jă>�2��[̓ ��=�{�* #�[Os#r�ͤ:��:�̤:���:��:���l�!� ~2���#�O ��x2�=��(͘ �:��(��=ɯ�!="t"v"x!  "|"~r!�|ͺ> 6:s�(� � (�F(#�q(�K}:|!s���2�͒(�2�=�2�2�!��~��G~� > #���*t�#~� +~�/(�>8!s�2|�=��~�/(��>2s>2|��>�*t~�A8��7>��CQy2_�(++"M2��=ɯ>�  P>,*x� *v� *z�(>�8�C}�=ɯ>2���?/Q�R�X5SlZ� ��"a5AR[	{�>�*��wT]�K���=2��:��(+ *MT]	��(�����T]����!�5*��B"�=2�ɯ>�:��(**M
 	"x�a:��(�!="x:��(�*M##"v�a!="x�a*z"x:��ʟ!=b ��*vb ���*xj ��!b�[M ��=2��!�:��(4*M�KQp#q#�h2�ɯ>�>�2��5*�T]�K��w�����!��[�*� ���4 �� ��S��*�"�*��[�"�*���R�"����:�<� !N�[�!��(�(�,�P�: > w#�=2�x2��w�S�=�6 #6,#> �:��(9:�(�� :�(%��type ? or / for error diagnosis
 ��Command (? for help):  �2�=!�͇"�2��h��h:������ No Entries in Directory ����Entries - ��*��   Maximum - :��*�h�h�� DU : DIR Name - Password     � �h��----  --------   --------     �J�h *�~�(T�ʊG���h �~�@͢#~�*��:  #���� -  ������     �y��h�y~͢#��y��h����h�=�* #�~#fo"O�5s#r*	###�f�m��h���r"�2��"�"�*� �S��  }�o"���[�"�"��[��"��2�:��  :2���(	#� ���=�!�!8!���5*t#~���2�͒��#~� �=�:/2�:/2�:/2�!�!����*t##~�(O!����!����y22��>ɯ>�F###~�>	�###���/H�B�E�O�0�C�S�:��(F=�O !x	~#fo���
???????---> !�����<---

 ����h�2�!�:� =�!Q��:����5���!�� ��*�"�ͣ����*��[��K����C��C��C��=�����K����%��C�͌�������f��ɾ�����>
�O~͢#� �=��Sorry - Wheel privileges are required for this pgm.
 Can't find System Named Directory!
 This is a ZCPR3 program which must 
be installed with Z3INS.
 ��	P	�	�	 
2
q

		ERROR CODE DESCRIPTIONS

Code 1 - First argument is invalid. Missing space?
Code 2 - First arg interpreted as invalid DU or DIR form.
Code 3 - For this command, the DU must exist in the NDR.
Code 4 - NDR buffer is full. The append was not performed.
Code 5 - Too many arguments. Missing command separator?
Code 6 - Too many commas. Only one has syntactic meaning.
Code 7 - New command separator was not supplied.
Code 8 - Invalid option character. Missing command separator?
Code 9 - Invalid separater. It's a command or option char!

One of these code values will be placed in the ZCPR3 program
error byte (where IF can find it) when an error occurs in a
command in the invoking command line. In the interactive mode
no errors are reported to the operating system.

 
		COMMAND OPTIONS (preceded by "/")

/	Display Help. If error, show error diagnostic
H	Toggle display of help after error diagnostic
B	Toggle audible notice of command error
E	Toggle visual notice of command error
S<ch>	Change command separator to character <ch>
O	Display this screen of option selections
C	Display the list of error codes

Option commands start with '/' and end with a carriage
return or command separator. Multiple options from the
list above may be included in any order. For example,
	/hbeo<cr>	is perfectly acceptable.
Note that if you assign a new separator, the assignment
takes place immediately, and your next separator must be
the one you assigned!

 
		EDITND version 1.1b
	EDIT resident Named Directory

SYNTAX:    EDITND  [<command>  [ \ <command>]...]
	<command> = <verb> [name] [,] [password]

Typical Commands ( [xxx] means xxx is optional)
(DU/DIR)[:]		delete Named Directory entry
(DU/DIR)[:] NAME	add/change a directory name only
(DU/DIR)[:] NAME,[PW]	add/change name & password
(DU/DIR)[:] ,[PW]	Change password only
(DU/DIR)[:] [NAME],	Password is deleted.

? or / or //		Display Help & Explain last error.
<CR>			empty cmd shows current NDR.
Q or q			Quit & return to Z (no changes)
R or r			Restart with original NDR
S or s			Sort the NDR entries
X or x			eXit to Z with .NDR updated
Z or z			Zap (erase) ALL NDR entries
/oo...			Other options. Type /O to see them.

                                                                                                                                                             ��                                                                                                                                                                                                                    �  �                                                                                      �����~����.#~+��.##�=�� 	����2����o�:���]͆�i���i��k���i͆�Y>�����4�}#�o�> �}���ͳ��Ͷx2�y2���G~�Aڷ���2�#�4��͍����4��͍��#º�4�����O�Y�����2�:�G:�O��=�����������$���$����#����(� 	�� ���OG��=�~͇�!�W�=��_��.��:��,��<��>ȷ��;ɯ�� ~�4ʆ#͍ڊWyڊڊ�ڊڊ�ڊO�]y����7��0��
җ?�7�           ����� �w�����*#. ~����*#$ ~#fo�|����*#, ~����*#" ~#fo�����*#- ~����*# ^#V#~�ѷ���*#) ~#fo~���"#�  ����"pr���"z*t}�o|�g�i�*z}�o|�g�i"r*p�!r����*r>�����*z��                            �����r��*t"~DMx�¬y���:|���*r�*zx���s#r#�*v��ú*~"��*�|g}o��3"�"�*�#"��*~}�|���*�"�*��*�}�o|�g"���|����*�"��;��*��*���� :|���*t"�*z"�*r"�*�DM*��*���c�ʅy��X��
SORT Pointer Error �  *�~#~*vDM*��*�~#fo��N�q��#x� *v�*�"�*�##"�*�+"�|��L�����:|�� ���*vDM��Nwy#�x������"���*��  *vDM!  z��	��*r��*zDM�+)	�+)	N�q#N�q�:|��H���`�*zDM�+)	�+)	�N#F�^#V`i�*x���H �o�������#x��rʃ?������2�"��
� *�#~#�o|� g6 �:��ʻ�~�ʺ͇w#í���+~#�   �������� ~#���	��u����
���������� ����y�����y�G>�G�O> ͢���������� �/���d�B
�B�0͢���� ��L�D�_y��^��^> ͢{� y�0͢{��>͢>
͢��� Ң� ʢ�ʢ�ʢ�
ʢ�ʢ��>^͢��@͢������O* .������������ �� � O�G�������H 	�	������	�	����H ��������|����}��~#x��������	�	�~+x�����կ2��!  "���h�M�*�}�o|�g"��L>�2����v��1��*�:���e�7�����|g}o�e�b��}o|g�e�b   ��a��{��_��bk��F#"�##�ʯ###*�ð#~#fo����  ���O�F�##�����s#r#������y����x�������������~�#w������� ���	������ ��	���*)}��'$. ��+                                                                                     