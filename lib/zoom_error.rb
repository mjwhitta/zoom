module ZoomError
    class Error < RuntimeError
    end

    class ExecutableNotFoundError < Error
        def initialize(exe)
            super("Executable #{exe} not found!")
        end
    end

    class ProfileAlreadyExistsError < Error
        def initialize(profile)
            super("Profile #{profile} already exists!")
        end
    end

    class ProfileCanNotBeModifiedError < Error
        def initialize(profile)
            super("Profile #{profile} can not be modified!")
        end
    end

    class ProfileClassUnknownError < Error
        def initialize(clas)
            super("Profile class #{clas} unknown!")
        end
    end

    class ProfileDoesNotExistError < Error
        def initialize(profile)
            super("Profile #{profile} does not exist!")
        end
    end
end
