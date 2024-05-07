Label: Nhãn của mẫu yêu cầu (request sample). Đây thường là tên của sampler mà bạn đã sử dụng trong kịch bản của mình.

Samples: Số lượng mẫu đã được thực hiện cho mỗi nhãn.

Average: Trung bình thời gian thực hiện của mỗi mẫu (trong milliseconds).

Median: Thời gian trung vị của các mẫu (thời gian của mẫu ở vị trí giữa khi tất cả các mẫu được sắp xếp).

90% Line: Thời gian mà 90% của các mẫu hoàn thành dưới giới hạn này.

Min: Thời gian thực hiện ngắn nhất của một mẫu.

Max: Thời gian thực hiện dài nhất của một mẫu.

Error%: Tỷ lệ phần trăm của các mẫu gặp lỗi so với tổng số mẫu.

Throughput: Số lượng mẫu hoàn thành trung bình mỗi giây.

Received KB/sec: Tổng dung lượng dữ liệu nhận được mỗi giây (dưới dạng KB).

Sent KB/sec: Tổng dung lượng dữ liệu gửi đi mỗi giây (dưới dạng KB).

KB/sec: Tổng dung lượng dữ liệu gửi và nhận mỗi giây (dưới dạng KB).


Average (Trung bình): Đây là giá trị trung bình của một tập hợp các số

Median (Trung vị): Đây là giá trị ở vị trí giữa của một tập hợp dữ liệu được sắp xếp. Để tính toán trung vị, bạn cần sắp xếp tập hợp dữ liệu theo thứ tự tăng dần hoặc giảm dần và chọn giá trị ở vị trí giữa. Trong trường hợp tập hợp có số lượng lẻ, trung vị sẽ là giá trị ở giữa; trong trường hợp tập hợp có số lượng chẵn, trung vị sẽ là trung bình của hai giá trị ở giữa.

Deviation (Độ lệch chuẩn): Đây là một chỉ số đo lường mức độ phân tán của dữ liệu xung quanh giá trị trung bình. Bạn có thể tính độ lệch chuẩn bằng cách sử dụng các công thức và công cụ thống kê phù hợp, như công thức độ lệch chuẩn dự đoán hoặc các chức năng trong các công cụ phân tích dữ liệu như Excel, R hoặc Python.
Throughput: Đường biểu thị số lượng yêu cầu hoàn thành trung bình mỗi giây. Đây là một chỉ số quan trọng để đo lường khả năng xử lý của ứng dụng.

Response Time: Đường biểu thị thời gian trung bình mà một yêu cầu mất để được xử lý, thường được tính từ lúc gửi yêu cầu cho đến khi nhận được phản hồi.

Active Threads Over Time: Đường biểu thị số lượng luồng hoạt động trong quá trình thử nghiệm theo thời gian. Điều này giúp bạn xem xét tải của hệ thống trong suốt quá trình thử nghiệm.

Latencies Over Time: Đường biểu thị thời gian đợi trung bình mà một yêu cầu phải chờ trước khi bắt đầu được xử lý. Đây là một chỉ số quan trọng để đánh giá sự chậm trễ trong hệ thống của bạn.

Response Codes per Second: Biểu đồ cung cấp số lượng các mã trạng thái phản hồi khác nhau mỗi giây. Điều này giúp bạn theo dõi tỷ lệ thành công và lỗi của các yêu cầu.

Connect Time Over Time: Đường biểu thị thời gian mà một yêu cầu mất để thiết lập kết nối với máy chủ.



jmeter.bat -n -t D:\CTS_LoadTest\Module\Classification\NormalByGeneral\CTSClassification_NormalByGeneral.jmx -l D:\CTS_LoadTest\Module\Classification\NormalByGeneral\CTSClassification_NormalByGeneral_RPT.jtl

jmeter.bat -g D:\CTS_LoadTest\Module\Classification\NormalByGeneral\CTSClassification_NormalByGeneral_RPT.jtl -o D:\CTS_LoadTest\Module\Classification\NormalByGeneral\Report