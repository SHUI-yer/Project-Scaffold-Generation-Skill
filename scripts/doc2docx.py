"""
doc2docx.py — 将 .doc 文件转换为 .docx 格式
用法：python scripts/doc2docx.py <input文件夹>
依赖：pip install pywin32（Windows 自带 Word 或 WPS 时可用）
"""
import sys
import os
from pathlib import Path


def convert_with_word(doc_path: str, docx_path: str) -> bool:
    """使用 Microsoft Word 转换"""
    try:
        import win32com.client
        word = win32com.client.Dispatch("Word.Application")
        word.Visible = False
        doc = word.Documents.Open(os.path.abspath(doc_path))
        doc.SaveAs2(os.path.abspath(docx_path), FileFormat=16)  # 16 = wdFormatXMLDocument (.docx)
        doc.Close()
        word.Quit()
        return True
    except Exception as e:
        print(f"  Word 转换失败：{e}")
        try:
            word.Quit()
        except:
            pass
        return False


def convert_with_wps(doc_path: str, docx_path: str) -> bool:
    """使用 WPS Office 转换"""
    try:
        import win32com.client
        wps = win32com.client.Dispatch("kwps.Application")
        wps.Visible = False
        doc = wps.Documents.Open(os.path.abspath(doc_path))
        doc.SaveAs2(os.path.abspath(docx_path), FileFormat=16)
        doc.Close()
        wps.Quit()
        return True
    except Exception as e:
        print(f"  WPS 转换失败：{e}")
        try:
            wps.Quit()
        except:
            pass
        return False


def main():
    if len(sys.argv) < 2:
        print("用法：python doc2docx.py <input文件夹>")
        print("示例：python doc2docx.py input/")
        sys.exit(1)

    input_dir = Path(sys.argv[1])

    if not input_dir.exists():
        print(f"错误：目录不存在 {input_dir}")
        sys.exit(1)

    # 查找所有 .doc 文件（排除 .docx）
    doc_files = [f for f in input_dir.glob("*.doc") if f.suffix == ".doc"]

    if not doc_files:
        print(f"在 {input_dir} 中未找到 .doc 文件")
        sys.exit(0)

    # 检查 pywin32
    try:
        import win32com.client
    except ImportError:
        print("错误：需要安装 pywin32")
        print("请运行：pip install pywin32")
        print("注意：此工具仅在 Windows 上可用，且需要安装 Word 或 WPS")
        sys.exit(1)

    success_count = 0
    for doc_file in doc_files:
        docx_file = doc_file.with_suffix(".docx")
        print(f"转换：{doc_file.name} -> {docx_file.name}")

        # 尝试 Word
        if convert_with_word(str(doc_file), str(docx_file)):
            print(f"  -> 成功（使用 Microsoft Word）")
            success_count += 1
            continue

        # 尝试 WPS
        if convert_with_wps(str(doc_file), str(docx_file)):
            print(f"  -> 成功（使用 WPS Office）")
            success_count += 1
            continue

        print(f"  -> 失败（未检测到 Word 或 WPS）")

    print(f"\n完成！成功转换 {success_count}/{len(doc_files)} 个文件")
    if success_count < len(doc_files):
        print("提示：请确保已安装 Microsoft Word 或 WPS Office")


if __name__ == "__main__":
    main()
