#ifndef __FILE_H__
#define __FILE_H__


class File
{
	public:
		File();
		~File();
	
	public:
		static const char* getName(const char* filePath);
		static void getName(const char* filePath, char* fileName);
		static void getNameWithoutExt(const char* filePath, char* fileName);
		static const char* getExtension(const char* filePath);
};

#endif	// __FILE_H__
