--     a. Liệt kê ho_ten_hs, gioi_tinh, dia_chi của các nhóm được phân nhóm theo ho_ten_hs và gioi_tinh trong bảng hoc_sinh. Thử suy nghĩ về nguyê nhân lỗi nếu có lỗi xảy ra (*)
select ho_ten_hs, gioi_tinh, dia_chi
from hoc_sinh
group by ho_ten_hs, gioi_tinh, dia_chi;
-- Giải thích lỗi: Lỗi xảy ra vì dia_chi không nằm trong mệnh đề GROUP BY và cũng không nằm trong một hàm gộp (như MAX, MIN). 
-- SQL không biết chọn địa chỉ nào nếu có 2 học sinh trùng tên và giới tính nhưng khác địa chỉ. Để sửa, cần thêm dia_chi vào GROUP BY. hoặc tắt ONLY_FULL_GROUP_BY


--     b. Đếm số lượng học sinh là nam.
select count(*) as so_luon_gnam
from hoc_sinh
where gioi_tinh = 'nam';

--     c. Đếm số lượng học sinh trong lớp có tên là Lớp 1A và lớp đó nằm trong năm học 2022-2023.
select count(*) as so_luong_hoc_sinh
from hoc_sinh inner join lop on hoc_sinh.ma_lop = lop.ma_lop
where lop.ten_lop = 'lop 1a' and lop.nam_hoc = '2022-2023';

--     d. Đếm số lớp đã phụ trách (có thể là 1 hoặc nhiều môn nào đó) của từng giáo viên.
select gv.ma_gv, gv.ho_ten_gv, count(distinct ptbm.ma_lop) as so_luong_lop_phu_trach
from giao_vien gv
left join phu_trach_bo_mon ptbm on gv.ma_gv = ptbm.ma_gvpt
group by gv.ma_gv, gv.ho_ten_gv;

--     e. Đếm những môn học đã từng có học sinh thi giữa kỳ được 9 điểm trở lên. (*). Gợi ý: làm theo 2 cách, 1 là dùng WHERE, 2 là dùng HAVING.
select 
    ma_mh, 
    count(*) as so_luong_dat_diem
from ket_qua_hoc_tap
where diem_thi_giua_ky >= 9
group by ma_mh;

-- cách 2
select 
    ma_mh, 
    count(*) as so_luong
from (
    select ma_mh, ma_hs
    from ket_qua_hoc_tap
    group by ma_mh, ma_hs, diem_thi_giua_ky
    having diem_thi_giua_ky >= 9
) as danh_sach_gioi
group by ma_mh;

--     f. Đếm xem tương ứng với mỗi địa chỉ (của học sinh), số lượng học sinh đang ở mỗi địa chỉ là bao nhiêu em.
select dia_chi, count(*) as so_luong_hoc_sinh
from hoc_sinh
group by dia_chi;

--     g. Liệt kê điểm thi cao nhất của từng môn học (dựa vào điểm thi cuối kỳ mà các học sinh đã từng thi).
select mh.ten_mh, max(kq.diem_thi_cuoi_ky) as diem_thi_cao_nhat
from mon_hoc mh
join ket_qua_hoc_tap kq on mh.ma_mh = kq.ma_mh
group by mh.ten_mh;

--     h. Liệt kê điểm thi trung bình của từng môn học (dựa vào điểm thi cuối kỳ mà các học sinh đã từng thi).
select mh.ten_mh, avg(kq.diem_thi_cuoi_ky) as diemthitrungbinh
from mon_hoc mh
join ket_qua_hoc_tap kq on mh.ma_mh = kq.ma_mh
group by mh.ten_mh;

--     i. Liệt kê những môn học có điểm thi trung bình cao nhất (dựa vào điểm thi cuối kỳ mà các học sinh đã từng thi). 
-- Gợi ý: có trường hợp nhiều hơn 1 môn học có điểm thi trung bình cao nhất. (**)
SELECT 
    mh.ten_mh, AVG(kq.diem_thi_cuoi_ky) AS diem_thi_trung_binh
FROM
    mon_hoc mh
        JOIN
    ket_qua_hoc_tap kq ON mh.ma_mh = kq.ma_mh
GROUP BY mh.ten_mh
HAVING AVG(kq.diem_thi_cuoi_ky) = (SELECT 
        AVG(diem_thi_cuoi_ky) AS max_avg
    FROM
        ket_qua_hoc_tap
    GROUP BY ma_mh
    ORDER BY max_avg DESC
    LIMIT 1);

--     j. Tính điểm thi trung bình của từng học sinh trong trường. Chỉ tính điểm trung bình cho những học sinh đã từng thi cuối kỳ cho ít nhất 1 môn. Dựa vào cột điểm thi cuối kỳ để tính.
SELECT hs.ma_hs, hs.ho_ten_hs, AVG(kq.diem_thi_cuoi_ky) AS diem_tb
FROM hoc_sinh hs
JOIN ket_qua_hoc_tap kq ON hs.ma_hs = kq.ma_hs
GROUP BY hs.ma_hs, hs.ho_ten_hs
HAVING COUNT(kq.diem_thi_cuoi_ky) >= 1;

--     k. Tìm học sinh có điểm thi trung bình các môn học cao nhất của lớp 1A trong năm học 2022-2023. 
-- Nếu có nhiều hơn 1 em thỏa mãn yêu cầu thì sẽ xét ưu tiên theo họ tên (sắp xếp họ tên theo A-Z, chỉ ưu tiên cho 1 em đứng trước trong danh sách). 
-- Dựa vào cột điểm thi cuối kỳ để tính. (Gợi ý: tương tự câu i nhưng có thêm ORDER BY)
select 
    hs.ma_hs, 
    hs.ho_ten_hs, 
    avg(kq.diem_thi_cuoi_ky) as diem_tb
from hoc_sinh hs
join lop l on hs.ma_lop = l.ma_lop
join ket_qua_hoc_tap kq on hs.ma_hs = kq.ma_hs
where l.ten_lop = 'lớp 1a' and l.nam_hoc = '2022-2023'
group by hs.ma_hs, hs.ho_ten_hs
order by diem_tb desc, hs.ho_ten_hs asc
limit 1;


--     l. Tìm họ tên của những giáo viên đã từng dạy những học sinh có điểm trung bình cao nhất (xét trên dữ liệu của bất kể môn gì, chỉ tính điểm thi cuối kỳ của học kỳ 2). (***) (Suy nghĩ cẩn thận trước khi quyết định làm)
